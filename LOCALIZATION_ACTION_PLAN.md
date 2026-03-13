# Localization Audit - Quick Action Plan

## 🔴 CRITICAL: Missing Translation Keys (Add Immediately)

Add these keys to **BOTH** `app_localizations_ar.dart` AND `app_localizations_en.dart`:

```dart
// 1. minimumDepositColon
'minimumDepositColon': 'الحد الأدنى المطلوب: ',  // AR
'minimumDepositColon': 'Minimum Deposit Required: ',  // EN

// 2. failedPaymentUrl
'failedPaymentUrl': 'فشل تجهيز رابط الدفع',  // AR
'failedPaymentUrl': 'Failed to prepare payment link',  // EN

// 3. errorProcessingPayment
'errorProcessingPayment': 'خطأ أثناء معالجة الدفع',  // AR
'errorProcessingPayment': 'Error processing payment',  // EN

// 4. no_places_found
'no_places_found': 'مفيش أماكن موجودة',  // AR
'no_places_found': 'No places found',  // EN

// 5. pleaseSelectTimeSlot
'pleaseSelectTimeSlot': 'الرجاء اختيار وقت للحجز أولاً',  // AR
'pleaseSelectTimeSlot': 'Please select a time slot first',  // EN

// 6. fieldRequired
'fieldRequired': 'هذا الحقل مطلوب',  // AR
'fieldRequired': 'This field is required',  // EN

// 7. myPlaces
'myPlaces': 'أماكني',  // AR
'myPlaces': 'My Places',  // EN

// 8. step_basic_info
'step_basic_info': 'المعلومات الأساسية',  // AR
'step_basic_info': 'Basic Information',  // EN

// 9. errorSaving
'errorSaving': 'خطأ أثناء الحفظ: ',  // AR
'errorSaving': 'Error saving: ',  // EN

// 10. currency (if not exists)
'currency': 'ج.م',  // AR
'currency': 'LE',  // EN
```

---

## 🟡 HIGH PRIORITY: Replace Hardcoded Strings

### booking_summary_dialog.dart (6 strings)
```dart
// BEFORE:
child: const Text("تراجع"),
child: const Text("تأكيد"),

// AFTER:
child: Text(context.tr('cancel')),
child: Text(context.tr('confirm')),

// For form inputs:
decoration: const InputDecoration(labelText: "اسم العميل"),
// AFTER:
decoration: InputDecoration(labelText: context.tr('fullName')),
```

### payment_status_dialog.dart (3 strings)
Replace with:
```dart
context.tr('paymentSuccess')  // New key needed: "عملية ناجحة!" / "Payment Successful!"
context.tr('bookingConfirmed')  // "تم تأكيد الحجز بنجاح" / "Booking confirmed successfully"
context.tr('paymentFailed')  // "للأسف حصل مشكلة أثناء الدفع" / "Payment failed"
context.tr('ok')  // Already exists: "تمام" / "OK"
```

### place_card.dart (2 strings)
```dart
// Line 146:
content: Text(context.tr('placeDeletedSuccessfully')),

// Line 152:
content: Text(context.tr('errorDeletingPlace')),  // NEW: "فشل حذف المكان" / "Error deleting place"
```

### show_success_dialog.dart (2 strings)
```dart
title: context.tr('successTitle'),  // "نجاح العملية" / "Success"
desc: context.tr('successMessage'),  // "تمت العملية بنجاح" / "Operation completed successfully"
```

### signup_page.dart (1 string)
```dart
// Line 88:
content: Text(context.tr('codeSentSuccess')),  // "تم إرسال الكود بنجاح" / "Code sent successfully"
```

### payment_web_view.dart (1 string)
```dart
// Line 87:
title: const Text(context.tr('confirmPayment')),  // "تأكيد دفع المحفظة" / "Confirm Wallet Payment"
```

### map_selection_screen.dart (1 string)
```dart
content: Text(context.tr('locationNotFound')),  // "لم نتمكن من العثور على المكان" / "Location not found"
```

---

## 📝 New Keys Needed (Create If Not Exists)

| Key | Arabic | English |
|-----|--------|---------|
| `paymentSuccess` | عملية ناجحة! | Payment Successful! |
| `bookingConfirmed` | تم تأكيد الحجز بنجاح | Booking confirmed successfully |
| `paymentFailed` | للأسف حصل مشكلة أثناء الدفع | Payment failed |
| `errorDeletingPlace` | فشل في حذف المكان | Error deleting place |
| `successTitle` | نجاح العملية | Success |
| `successMessage` | تمت العملية بنجاح | Operation completed successfully |
| `codeSentSuccess` | تم إرسال الكود بنجاح | Code sent successfully |
| `confirmPayment` | تأكيد الدفع | Confirm Payment |
| `locationNotFound` | لم نتمكن من العثور على المكان | Location not found |

---

## 🟢 OPTIONAL: Dead Keys to Remove

These keys exist in translation files but are NEVER used in code. Safe to remove:

```dart
// Remove from both files:
'login'
'email' 
'password'
'forgotPassword'
'dontHaveAccount'
'alreadyHaveAccount'
'userNotFound'
'wrongPassword'
'emailAlreadyInUse'
'invalidEmail'
'emailRequired'
'passwordRequired'
'dontHaveAccountSignUp'
'JaneDoe'
'Iagre'
'home'
'places'
'bookingPage'
'noSlotsAvailable'
'selectDate'
'selectTime'
'availableTimeSlotsFor'
'notAvailableShort'
'openClose'
'placeDetails'
'noPriceAvailable'
'noPlayersInfo'
'viewDetails'
'about'
'sectionColon'
'loading'
'ok'
'noBookingsFound'
'noData'
'deleteConfirmation'
'failed'
'uploadSubPlacePhoto'
'addField'
'photoRequired'
'gallery'
'camera'
'size'
'edit'
'delete'
'confirmDeletion'
'areYouSureDelete'
'bookingsFor'
'bookingDeletedSuccessfully'
```

---

## ⚠️ Inconsistency Fixes

### Naming Convention Issues

1. **Case Inconsistency:**
   - `Confirm` vs `confirm` vs `Cancel` vs `cancel`
   - Fix: Use lowercase for all UI buttons

2. **Underscore vs Camel Case:**
   - `no_places_found` (underscore) vs `noPlacesFound` (camel)
   - Fix: Migrate all to snake_case

3. **AppLocalizations vs context.tr():**
   - Some files use `AppLocalizations.of(context)!.translate(key)`
   - Others use `context.tr(key)`
   - Fix: Standardize to `context.tr()` everywhere

---

## 💡 Testing & Validation

After making changes, verify:

```bash
# 1. Check all keys exist in both languages
grep -o "'[a-zA-Z_]*'" lib/core/localization/app_localizations_ar.dart | \
  sort > keys_ar.txt
grep -o "'[a-zA-Z_]*'" lib/core/localization/app_localizations_en.dart | \
  sort > keys_en.txt
diff keys_ar.txt keys_en.txt  # Should be identical

# 2. Check for unused debug prints
grep -r "print(" lib/ | grep -v "test" | wc -l

# 3. Find any remaining hardcoded Arabic text
grep -r "Text(" lib/ | grep -E "[ء-ي]" | grep -v context.tr
```

---

**Total Effort:** 2-3 hours  
**Risk Level:** Low (string changes only)  
**Testing Required:** Manual UI testing for all modified screens
