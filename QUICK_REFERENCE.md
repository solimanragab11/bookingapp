# 🎯 Quick Reference - Restricted Booking Management

## Core Implementation Files

### 1. **Data Model** (Already Updated)
- **File:** `lib/core/models/booking_model.dart`
- **Field Added:** `String bookedBy` ('user' or 'owner')
- **Status:** ✅ fromJson/toJson already support bookedBy

---

## 2. **BookingService - Enhanced Methods**
**File:** `lib/core/db/booking_service.dart`

```dart
// Add manual booking by owner
Future<void> addOwnerBooking({...}) // Hardcodes bookedBy: 'owner'

// Delete booking with restrictions
Future<bool> cancelBooking({
  required String bookingId,
  required String bookedBy,
})
// ✅ Allow if bookedBy == 'owner'
// ❌ Throw Exception if bookedBy == 'user'

// Count app bookings in a month
Future<int> countAppBookings({
  required String placeId,
  required DateTime month,
})

// Get detailed bookings for analytics
Future<List<BookingModel>> getAppBookingsForMonth({...})

// Get single booking by ID
Future<BookingModel?> getBookingById(String bookingId)
```

---

## 3. **Cubit States - New**
**File:** `lib/features/owner/logic/booking_management_cubit/booking_mng_states.dart`

```
AddOwnerBookingLoading
AddOwnerBookingSuccess(bookingId, message)
AddOwnerBookingFailure(message)

CancelBookingLoading
CancelBookingSuccess(bookingId, message)
CancelBookingFailure(message, reason) // reason: 'PROTECTED_BOOKING' or 'CANCEL_ERROR'

FetchBookingsLoading
FetchBookingsSuccess(appBookingCount, ownerBookingCount, totalAppBookingRevenue)
FetchBookingsFailure(message)
```

---

## 4. **Cubit Methods - New**
**File:** `lib/features/owner/logic/booking_management_cubit/booking_mng_cubit.dart`

```dart
// Add manual booking
Future<void> addOwnerBooking({...})

// Cancel booking with protection
Future<void> cancelBooking({
  required String bookingId,
  required String bookedBy,
})

// Get monthly analytics
Future<void> fetchMonthlyBookingAnalytics({
  required String placeId,
  required DateTime month,
})

// Helper: get booking origin
Future<String?> getBookingOrigin(String bookingId)
```

---

## 5. **Analytics Service** - Comprehensive
**File:** `lib/core/services/booking_analytics_service.dart`

Key Methods:
```dart
countAppBookingsForMonth()
countOwnerBookingsForMonth()
countTotalBookingsForMonth()
getAppBookingsForMonth()
getOwnerBookingsForMonth()
calculateAppBookingRevenue()
calculateOwnerBookingRevenue()
calculateAverageBookingValue()
getMonthlyReport() // Returns formatted report
```

**Report Model:**
```dart
class BookingMonthlyReport {
  int appBookingCount;
  int ownerBookingCount;
  int totalBookingCount;
  double appBookingRevenue;
  double ownerBookingRevenue;
  double totalRevenue;
  double appBookingPercentage;
}
```

---

## 6. **UI Widget** - Complete
**File:** `lib/features/owner/presentation/widgets/owner_booking_management_widget.dart`

Features:
- ✅ Filter chips (All, App Bookings, Manual Entry)
- ✅ Booking cards with type badges
  - 🟢 Green badge for app bookings (bookedBy: 'user')
  - 🟠 Orange badge for owner bookings (bookedBy: 'owner')
- ✅ Delete button (enabled for owner bookings only)
- ✅ Lock icon with tooltip (for app bookings)
- ✅ Delete confirmation dialog
- ✅ BLoC integration for success/failure states

---

## 🚀 Usage Examples

### Add Manual Booking
```dart
context.read<ManageBookingPlaceCubit>().addOwnerBooking(
  bookingId: 'manual_001',
  placeId: 'place_123',
  subPlaceId: 'subplace_456',
  bookingDate: DateTime.now(),
  timeSlots: {'Saturday': ['10:00', '11:00']},
  totalPrice: 100.0,
  paidAmount: 100.0,
  requiredDeposit: 50.0,
  userId: 'customer_123',
  isCash: true,
);
// ✅ bookedBy automatically set to 'owner'
```

### Delete Booking (with Protection)
```dart
context.read<ManageBookingPlaceCubit>().cancelBooking(
  bookingId: 'booking_001',
  bookedBy: 'owner', // ✅ Allowed
  // bookedBy: 'user', // ❌ Will throw exception
);

// Listen for success/failure
BlocListener<ManageBookingPlaceCubit, ManageBookingPlaceState>(
  listener: (context, state) {
    if (state is CancelBookingSuccess) {
      print('Booking deleted: ${state.message}');
    } else if (state is CancelBookingFailure) {
      if (state.reason == 'PROTECTED_BOOKING') {
        print('App bookings are protected');
      }
    }
  },
)
```

### Get Monthly Analytics
```dart
context.read<ManageBookingPlaceCubit>().fetchMonthlyBookingAnalytics(
  placeId: 'place_123',
  month: DateTime(2024, 3),
);

BlocListener<ManageBookingPlaceCubit, ManageBookingPlaceState>(
  listener: (context, state) {
    if (state is FetchBookingsSuccess) {
      print('App bookings: ${state.appBookingCount}');
      print('Total revenue: \$${state.totalAppBookingRevenue}');
    }
  },
)
```

### Get Detailed Monthly Report
```dart
final analyticsService = BookingAnalyticsService();
final report = await analyticsService.getMonthlyReport(
  placeId: 'place_123',
  month: DateTime(2024, 3),
);
print(report); // Formatted output with all metrics
```

### Integrate UI Widget
```dart
@override
Widget build(BuildContext context) {
  return OwnerBookingManagementWidget(
    placeId: 'place_123',
    bookings: myBookings,
    onDeleteTapped: (bookingId, bookedBy) {
      context.read<ManageBookingPlaceCubit>().cancelBooking(
        bookingId: bookingId,
        bookedBy: bookedBy,
      );
    },
  );
}
```

---

## 🔐 Protection Logic

```
┌─────────────────────────────────────────────┐
│         Booking Deletion Flow                │
├─────────────────────────────────────────────┤
│                                             │
│ cancelBooking(id, bookedBy) called          │
│         │                                   │
│         ├─→ bookedBy == 'user'?             │
│         │   YES → ❌ Throw Exception        │
│         │   "App-generated bookings can      │
│         │    only be managed by system      │
│         │    administration."                │
│         │                                   │
│         └─→ bookedBy == 'owner'?            │
│             YES → ✅ Delete & Return true   │
│                                             │
└─────────────────────────────────────────────┘
```

---

## 📊 Database Structure

**Firestore Collection:** `bookings`
```json
{
  "id": "booking_001",
  "bookedBy": "owner",              // ✅ NEW FIELD
  "userId": "user_123",
  "placeId": "place_123",
  "subPlaceId": "subplace_456",
  "bookingDate": "2024-03-15",
  "timeSlots": {
    "Saturday": ["10:00", "11:00"]
  },
  "totalPrice": 150.0,
  "paidAmount": 150.0,
  "requiredDeposit": 75.0,
  "isOffer": false,
  "offer": null,
  "priceAfterOffer": 150.0,
  "isCash": true
}
```

**Indexes Required:**
- `placeId, bookedBy, bookingDate`
- `placeId, bookingDate`

---

## ✅ Deliverables Completed

- [x] **BookingModel** - Updated with bookedBy field
- [x] **BookingService** - 5 new methods for owner bookings & analytics
- [x] **Cubit States** - 7 new states for booking operations
- [x] **Cubit Methods** - 4 new methods for booking management
- [x] **Analytics Service** - Comprehensive booking analytics
- [x] **UI Widget** - Complete booking management interface
- [x] **Documentation** - Comprehensive implementation guide

---

## 📝 Error Messages

| Error | Scenario |
|-------|----------|
| "App-generated bookings can only be managed by system administration." | Attempting to delete user booking |
| "Invalid bookedBy value: {value}" | Invalid bookedBy value in cancelBooking |
| "فشل التحديث الجماعي: {error}" | Bulk slot update failed |
| "فشل حذف الحجز: {error}" | General deletion error |

---

## 🧪 Testing Commands

```dart
// Test 1: Create owner booking
await BookingService().addOwnerBooking(
  bookingId: 'test_001',
  placeId: 'place_test',
  subPlaceId: 'subplace_test',
  bookingDate: DateTime.now(),
  timeSlots: {'Monday': ['09:00']},
  totalPrice: 50.0,
  paidAmount: 50.0,
  requiredDeposit: 25.0,
  userId: 'user_test',
  isCash: true,
);

// Test 2: Try to delete app booking (should fail)
try {
  await BookingService().cancelBooking(
    bookingId: 'app_booking',
    bookedBy: 'user',
  );
} catch (e) {
  assert(e.toString().contains('App-generated'));
}

// Test 3: Count app bookings
final count = await BookingService().countAppBookings(
  placeId: 'place_test',
  month: DateTime.now(),
);
```

---

**Status: ✅ Implementation Complete**
**Ready for: Integration & Testing**
