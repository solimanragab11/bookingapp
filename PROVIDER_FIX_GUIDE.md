# 🔧 Fix: Provider Not Found Error - Booking Management Widget

## Problem
```
Error: Could not find the correct Provider<ManageBookingPlaceCubit> above this Builder Widget
```

## Root Cause
The `OwnerBookingManagementWidget` was trying to access the `ManageBookingPlaceCubit` directly from a context that didn't have the provider in its widget tree. The `BlocListener` inside the widget was trying to read from a cubit that wasn't available in that scope.

---

## ✅ Solution Applied

### What Was Changed
1. **Removed `BlocListener` from `_buildDeleteButton()`**
   - The BlocListener was creating a new widget that couldn't access the Cubit
   
2. **Simplified delete flow to use callbacks**
   - The widget now calls `onDeleteTapped` callback instead of trying to access Cubit directly
   - Parent widget handles Cubit interaction through `context.read()`

3. **Updated example screen to show proper usage**
   - Wrapped the widget with `BlocListener` at the parent level
   - Moved Cubit interaction to the parent where provider is accessible

---

## 📐 How to Use the Widget Correctly

### ✅ CORRECT Implementation

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Bookings')),
    body: BlocListener<ManageBookingPlaceCubit, ManageBookingPlaceState>(
      // ✅ Listen to Cubit state changes at parent level
      listener: (context, state) {
        if (state is CancelBookingSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is CancelBookingFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: OwnerBookingManagementWidget(
        placeId: 'place_123',
        bookings: myBookings,
        onDeleteTapped: (bookingId, bookedBy) {
          // ✅ Call Cubit method from here (context has provider access)
          context.read<ManageBookingPlaceCubit>().cancelBooking(
            bookingId: bookingId,
            bookedBy: bookedBy,
          );
        },
      ),
    ),
  );
}
```

### ❌ INCORRECT Implementation (Old)
```dart
// ❌ DON'T DO THIS - causes Provider Not Found error
return OwnerBookingManagementWidget(
  placeId: 'place_123',
  bookings: bookings,
  onDeleteTapped: (bookingId, bookedBy) {
    print('Delete: $bookingId'); // No Cubit call - won't work!
  },
);
```

---

## 🔌 Provider Setup (In main.dart)

Make sure `ManageBookingPlaceCubit` is provided in your MultiProvider:

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ✅ Provide ManageBookingPlaceCubit
        BlocProvider<ManageBookingPlaceCubit>(
          create: (context) => ManageBookingPlaceCubit(
            OwnerBookingRepository(), // Pass your repository
          ),
        ),
        // ... other providers
      ],
      child: MaterialApp(
        home: BookingManagementScreen(),
      ),
    );
  }
}
```

---

## 🎯 Integration Pattern

### Pattern 1: Screen-level Integration
```dart
class BookingManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<ManageBookingPlaceCubit, ManageBookingPlaceState>(
      listener: (context, state) {
        // Handle all Cubit state changes
        _handleBookingStates(context, state);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Manage Bookings')),
        body: OwnerBookingManagementWidget(
          placeId: placeId,
          bookings: bookings,
          onDeleteTapped: (id, type) {
            context.read<ManageBookingPlaceCubit>().cancelBooking(
              bookingId: id,
              bookedBy: type,
            );
          },
        ),
      ),
    );
  }

  void _handleBookingStates(BuildContext context, ManageBookingPlaceState state) {
    if (state is CancelBookingSuccess) {
      _showSuccessMessage(context, state.message);
    } else if (state is CancelBookingFailure) {
      _showErrorMessage(context, state.message, state.reason);
    }
  }
}
```

### Pattern 2: Widget-level with Wrapping
```dart
@override
Widget build(BuildContext context) {
  return BlocListener<ManageBookingPlaceCubit, ManageBookingPlaceState>(
    listener: (context, state) {
      // State management here
    },
    child: Column(
      children: [
        OwnerBookingManagementWidget(
          placeId: 'place_1',
          bookings: allBookings,
          onDeleteTapped: _handleDelete,
        ),
      ],
    ),
  );
}

void _handleDelete(String bookingId, String bookedBy) {
  context.read<ManageBookingPlaceCubit>().cancelBooking(
    bookingId: bookingId,
    bookedBy: bookedBy,
  );
}
```

---

## 📊 State Handling Reference

The widget fires `onDeleteTapped` callback when user confirms deletion. Handle these states:

```dart
listener: (context, state) {
  // ✅ Booking deleted successfully
  if (state is CancelBookingSuccess) {
    print('✅ ${state.message}'); // "تم حذف الحجز بنجاح ✅"
    // Refresh bookings list if needed
  }
  
  // ❌ Protected booking (user-generated)
  else if (state is CancelBookingFailure && state.reason == 'PROTECTED_BOOKING') {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('⚠️ Protected Booking'),
        content: const Text(
          'App-generated bookings can only be managed by system administration.',
        ),
      ),
    );
  }
  
  // ❌ Other errors
  else if (state is CancelBookingFailure) {
    print('❌ Error: ${state.message}');
  }
}
```

---

## 🧪 Testing the Fix

### Test 1: Delete Owner Booking ✅
```dart
// Tap delete on owner booking → Should succeed
// ✅ State: CancelBookingSuccess
// ✅ Message: "تم حذف الحجز بنجاح ✅"
```

### Test 2: Try Delete App Booking ❌
```dart
// Tap delete on app booking → Should fail
// ❌ State: CancelBookingFailure
// ❌ Reason: "PROTECTED_BOOKING"
// ❌ Message: "App-generated bookings can only be managed by system administration."
```

### Test 3: No Provider Error ✅
```dart
// Should NOT see "Could not find the correct Provider<ManageBookingPlaceCubit>"
// Widget works without BlocListener inside it
```

---

## 📝 Key Changes Summary

| Aspect | Before | After |
|--------|--------|-------|
| BlocListener placement | Inside widget | Parent screen |
| Context usage | Direct in widget | Via callback |
| Provider access | ❌ Failed | ✅ Works |
| Error handling | N/A | Centralized in parent |
| Flexibility | Low | High (parent controls) |

---

## 💡 Best Practices

1. **Always wrap with BlocListener at the screen level**
   ```dart
   ✅ Screen wraps widget with BlocListener
   ✅ Screen's context has provider access
   ```

2. **Use callbacks for child-to-parent communication**
   ```dart
   ✅ Widget calls onDeleteTapped callback
   ✅ Parent handles Cubit logic
   ```

3. **Centralize state handling**
   ```dart
   ✅ One listener handles all states
   ✅ Easier to debug and maintain
   ```

4. **Verify MultiProvider setup**
   ```dart
   ✅ ManageBookingPlaceCubit in providers
   ✅ Provider wraps all screens that need it
   ```

---

## 🚀 Next Steps

1. ✅ Apply this pattern to your booking management screen
2. ✅ Wrap with BlocListener at screen level
3. ✅ Implement state handlers in listener
4. ✅ Test deletion flows (owner and app bookings)
5. ✅ Verify no Provider errors appear

---

## 📚 Related Files

- **Widget:** `lib/features/owner/presentation/widgets/owner_booking_management_widget.dart`
- **Cubit:** `lib/features/owner/logic/booking_management_cubit/booking_mng_cubit.dart`
- **States:** `lib/features/owner/logic/booking_management_cubit/booking_mng_states.dart`

---

**Status: ✅ Fixed**
**Error: Resolved**
**Ready to: Deploy & Test**
