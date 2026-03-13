# Localization Audit - Developer Quick Reference

## ⚡ 30-Second Summary

Your app has **89% localization coverage** but **17 critical hardcoded strings** need translation before release.

| Issue | Count | Time to Fix |
|-------|-------|------------|
| Missing keys | 9 | 15 min |
| Hardcoded strings | 17 | 90 min |
| Dead keys (optional) | 48+ | 30 min |
| **Total** | **74** | **2-3 hours** |

---

## 🚀 Quick Start: 3-Step Fix

### Step 1: Add Missing Keys (5 minutes)

Add these to BOTH `app_localizations_ar.dart` and `app_localizations_en.dart`:

```dart
// Add inside the map:
'minimumDepositColon': 'الحد الأدنى المطلوب: ',
'failedPaymentUrl': 'فشل تجهيز رابط الدفع',
'errorProcessingPayment': 'خطأ أثناء معالجة الدفع',
'no_places_found': 'مفيش أماكن موجودة',
'pleaseSelectTimeSlot': 'الرجاء اختيار وقت للحجز أولاً',
'fieldRequired': 'هذا الحقل مطلوب',
'myPlaces': 'أماكني',
'step_basic_info': 'المعلومات الأساسية',
'errorSaving': 'خطأ أثناء الحفظ: ',
```

English versions:
```dart
'minimumDepositColon': 'Minimum Deposit Required: ',
'failedPaymentUrl': 'Failed to prepare payment link',
'errorProcessingPayment': 'Error processing payment',
'no_places_found': 'No places found',
'pleaseSelectTimeSlot': 'Please select a time slot first',
'fieldRequired': 'This field is required',
'myPlaces': 'My Places',
'step_basic_info': 'Basic Information',
'errorSaving': 'Error saving: ',
```

### Step 2: Replace Hardcoded Strings (90 minutes)

Run find-and-replace for each file:

**booking_summary_dialog.dart:**
```diff
- child: const Text("تراجع"),
+ child: Text(context.tr('cancel')),

- child: const Text("تأكيد"),
+ child: Text(context.tr('confirm')),

- decoration: const InputDecoration(labelText: "اسم العميل"),
+ decoration: InputDecoration(labelText: context.tr('fullName')),

- decoration: const InputDecoration(labelText: "رقم التليفون"),
+ decoration: InputDecoration(labelText: context.tr('phoneNumber')),
```

**Other files:** See `LOCALIZATION_ACTION_PLAN.md` for detail replacements

### Step 3: Test (30 minutes)

```bash
# 1. Switch language in app settings - verify all text changes
# 2. Test booking flow - verify new keys display correctly
# 3. Test payment screen - verify deposit strings show
# 4. Test owner dashboard - verify "My Places" translates
# 5. Test form validation - verify "This field is required" works
```

---

## 📋 Files to Modify (17 Critical)

### High Priority (6 files - 30 min)
- [ ] `lib/features/owner/place_schedule/widgets/booking_summary_dialog.dart` (6 strings)
- [ ] `lib/features/user/payment/widgets/payment_status_dialog.dart` (3 strings)
- [ ] `lib/features/owner/dashboard/widgets/place_card.dart` (2 strings)
- [ ] `lib/core/widgets/show_success_dialog.dart` (2 strings)
- [ ] `lib/features/auth/presnations/signup_page.dart` (1 string)
- [ ] `lib/features/user/payment/payment_web_view.dart` (1 string)

### Medium Priority (2 files - 10 min)
- [ ] `lib/features/owner/add_place/widgets/map_selection_screen.dart` (1 string)
- [ ] `lib/features/owner/data/data_sources/image_picker_service.dart` (1 string)

### Low Priority (3 files - optional)
- [ ] `lib/features/auth/repo/firebase_auth_repo_impl.dart` (2 strings)
- [ ] `lib/features/auth/bloc/cubit/signup_cubit.dart` (1 string)

---

## ✅ Key Patterns to Remember

### DO ✅
```dart
// ✅ Good - Using translation extension
Text(context.tr('confirmBooking'))
context.tr('totalAmountColon')
showSnackBar(context, context.tr('message'), color)
InputDecoration(labelText: context.tr('fieldName'))

// ✅ Good - Using with default value
context.tr('key', defaultValue: 'Fallback')

// ✅ Good - Debug prints (can be hardcoded)
print("Debug: ${variable}");
debugPrint("Warning: This is a test");
```

### DON'T ❌
```dart
// ❌ Bad - Hardcoded string without translation
Text("This is hardcoded")
showSnackBar(context, "عملية ناجحة", Colors.green)
InputDecoration(labelText: "اسم العميل")

// ❌ Bad - Mixing translation methods
AppLocalizations.of(context)!.translate('key')

// ❌ Bad - Unsupported languages
context.tr('key_fr')  // FR not supported, only ar/en
```

---

## 🔍 Finding Issues in Your Code

### Search for hardcoded Arabic text:
```bash
grep -r "Text(" lib/ | grep -E "[ء-ي]" | grep -v "context.tr"
```

### Find all translation keys used:
```bash
grep -o "context\.tr('[^']*'" lib/ -r | sed "s/.*tr('//g" | sort -u
```

### Check for missing keys:
```bash
grep -o "context\.tr('[^']*'" lib/ -r | \
  sed "s/.*tr('//g" | \
  sed "s/'.*//g" | \
  sort -u > /tmp/used.txt

grep -o "'[^']*':" lib/core/localization/app_localizations_en.dart | \
  sed "s/'//g" | \
  sed "s/:.*//g" | \
  sort -u > /tmp/available.txt

comm -23 /tmp/used.txt /tmp/available.txt  # Shows missing keys
```

---

## 📊 Before & After Impact

### Before Audit
```
Hardcoded strings in UI: 17
Missing translation keys: 9
Code using old method: Some files
Translation file cleanliness: 66%
```

### After Fix (This Sprint)
```
Hardcoded strings in UI: 0 ✅
Missing translation keys: 0 ✅
Code using old method: 100% context.tr() ✅
Translation file cleanliness: 89% ✅
```

---

## Common Questions

**Q: Do I need to translate every string?**  
A: Yes, every user-facing string should be translated. Debug prints don't count.

**Q: What if I don't have the Arabic translation?**  
A: Use a translation service or ask your Arabic speaker on the team.

**Q: Why are there so many dead keys?**  
A: Likely from previous features or refactoring. Safe to delete if not used.

**Q: Should I use `context.tr()` or `AppLocalizations.of()`?**  
A: Always use `context.tr()` - it's shorter and works everywhere.

**Q: What if a string doesn't translate?**  
A: It will show the key name itself (e.g., `confirmBooking` if key not found). That's why finding missing keys is important.

---

## 🎯 Success Criteria

After implementing this audit, you should have:

- ✅ Zero hardcoded strings in user-facing UI
- ✅ All translation keys exist in both language files  
- ✅ Consistent use of `context.tr()` throughout code
- ✅ Clean translation files with no dead keys
- ✅ Standardized key naming (snake_case)
- ✅ App runs perfectly in both Arabic and English

---

## 📞 Need Help?

- **Question about a specific file?** See `LOCALIZATION_AUDIT_REPORT.md`
- **Want detailed action items?** See `LOCALIZATION_ACTION_PLAN.md`
- **Need all the tables?** See `LOCALIZATION_SUMMARY_TABLES.md`
- **Want implementation code snippets?** Ask in code review

---

**Audit Date:** February 27, 2026  
**Estimated Fix Time:** 2-3 hours  
**Difficulty:** Easy 🟢  
**Testing Effort:** Medium 🟡
