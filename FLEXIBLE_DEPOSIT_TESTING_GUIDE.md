# 🧪 Flexible Deposit Testing Guide

**Implementation Date:** February 27, 2026  
**Last Updated:** February 27, 2026

---

## 🎯 Quick Test Scenarios

### Test 1: Time Slot Selection & Min Deposit Calculation
**Goal:** Verify minRequiredDeposit calculates correctly based on hours

**Steps:**
1. Navigate to BookingPage
2. Select 1 hour time slot
3. Verify minRequiredDeposit = 100 EGP
   - Expected: `((1 + 2) ~/ 3) * 100 = 100`

**Expected Result:**
```
Hours: 1
Formula: ((1 + 2) ~/ 3) * 100
Result: (3 ~/ 3) * 100 = 1 * 100 = 100 ✅
```

---

### Test 2: Multiple Hours & Deposit Scaling
**Goal:** Verify formula works for various hour counts

| Hours | Formula | Expected | Test |
|-------|---------|----------|------|
| 1-3   | ((hrs+2)~/3)*100 | 100 | ✅ |
| 4     | ((4+2)~/3)*100 | 200 | ✅ |
| 5     | ((5+2)~/3)*100 | 200 | ✅ |
| 6     | ((6+2)~/3)*100 | 200 | ✅ |
| 7     | ((7+2)~/3)*100 | 300 | ✅ |
| 8     | ((8+2)~/3)*100 | 300 | ✅ |
| 9     | ((9+2)~/3)*100 | 300 | ✅ |

**Steps:**
1. Select 4 hours → Verify minRequiredDeposit = 200
2. Select 7 hours → Verify minRequiredDeposit = 300
3. Select 10 hours → Verify minRequiredDeposit = 400

---

### Test 3: Quick Action Buttons
**Goal:** Verify quick buttons set correct amounts

**Total Price Scenario:** 400 EGP (4-hour booking)

**Button Tests:**

#### Minimum Deposit Button
1. Click "Minimum Deposit" button
2. Verify amount field shows: 200
3. Verify border color = Green/Wasabi
4. Verify remaining = 200

#### Half Price Button
1. Click "Half Price" button
2. Verify amount field shows: 200
3. Verify remaining = 200

#### Full Price Button
1. Click "Full Price" button
2. Verify amount field shows: 400
3. Verify remaining = 0
4. Verify remaining color = Green

---

### Test 4: Custom Amount Input
**Goal:** Verify numeric input validation

**Test Cases:**

#### Valid Amount (Min)
1. Clear amount field
2. Type: 200 (min required)
3. Verify: No error message
4. Verify: Border = Green/Wasabi
5. Verify: Remaining = 200

#### Valid Amount (Mid-range)
1. Clear amount field
2. Type: 250
3. Verify: No error message
4. Verify: Border = Green
5. Verify: Remaining = 150

#### Valid Amount (Max)
1. Clear amount field
2. Type: 400 (full amount)
3. Verify: No error message
4. Verify: Border = Green
5. Verify: Remaining = 0

#### Invalid Amount (Below Min)
1. Clear amount field
2. Type: 150 (below min 200)
3. Verify: Error message appears
4. Error text: "Amount must be at least 200 LE"
5. Verify: Border = Red
6. Verify: Error icon appears

#### Invalid Amount (Above Max)
1. Clear amount field
2. Type: 500 (above max 400)
3. Verify: Error message appears
4. Error text: "Invalid amount"
5. Verify: Border = Red
6. Verify: Error icon appears

---

### Test 5: Real-time Validation
**Goal:** Verify validation happens as user types

**Steps:**
1. Amount field: "1" → Shows error (too low)
2. Continue typing: "15" → Still error
3. Continue typing: "200" → Error disappears ✅
4. Clear and type: "500" → Shows error (too high)
5. Delete last digit: "50" → Still error
6. Type correct amount: "300" → Error disappears ✅

**Expected:** Error appears/disappears dynamically

---

### Test 6: Remaining Amount Calculation
**Goal:** Verify remainingAmount = totalPrice - paidAmount

**Test Case:** Total = 400 EGP

| Paid | Remaining | Color | Test |
|------|-----------|-------|------|
| 100  | 300       | Orange | ✅ |
| 200  | 200       | Orange | ✅ |
| 300  | 100       | Orange | ✅ |
| 400  | 0         | Green  | ✅ |

**Steps:**
1. Enter 100 → Verify remaining = 300 (orange color)
2. Enter 200 → Verify remaining = 200 (orange color)
3. Enter 300 → Verify remaining = 100 (orange color)
4. Enter 400 → Verify remaining = 0 (green color)

---

### Test 7: Day Selection Reset
**Goal:** Verify payment fields reset when user changes day

**Steps:**
1. Select Monday + 4 hours → minDeposit = 200, set paid = 300
2. Switch to Tuesday
3. Verify: minDeposit = 0 (no slots selected yet)
4. Verify: paidAmount = 0
5. Verify: remainingAmount = 0
6. Select 2 hours on Tuesday → minDeposit = 100

---

### Test 8: Payment Method Integration
**Goal:** Verify payment methods use flexible amount

**Scenario:** Total = 400, User sets paid = 250

#### Option 1: Deposit Only (Flexible)
1. Click "Confirm and Book"
2. Select "Deposit Only" from bottom sheet
3. Verify: Payment initiated with **250 EGP** (not fixed 200)
4. Verify: Booking created with paidAmount = 250

#### Option 2: Full Amount
1. Click "Confirm and Book"
2. Select "Full Amount" from bottom sheet
3. Verify: Payment initiated with **400 EGP**
4. Verify: Booking created with paidAmount = 400

#### Option 3: Cash at Venue
1. Click "Confirm and Book"
2. Select "Cash at Venue" from bottom sheet
3. Verify: No payment processing
4. Verify: Booking created with paidAmount = 250 (recorded intent)

---

### Test 9: Localization - Arabic
**Goal:** Verify all UI text displays in Arabic

**Steps:**
1. Change device language to Arabic (العربية)
2. Restart app
3. Navigate to BookingPage
4. Verify: AppBar shows "تأكيد الحجز"
5. Verify: FlexiblePaymentInput shows:
   - Title: "اختر مبلغ دفع"
   - Quick Actions: "الخيارات السريعة"
   - Min Button: "الحد الأدنى"
   - Half Button: "نص السعر"
   - Full Button: "السعر الكامل"
   - Custom Label: "مبلغ مخصص"
   - Input hint: "أدخل المبلغ"
   - Currency: "ج.م"
   - Payment: "مبلغ الدفع"
   - Remaining: "المبلغ المتبقي"

**Expected:** All text in proper Arabic (RTL layout)

---

### Test 10: Localization - English
**Goal:** Verify all UI text displays in English

**Steps:**
1. Change device language to English
2. Restart app
3. Navigate to BookingPage
4. Verify: AppBar shows "Confirm Booking"
5. Verify: FlexiblePaymentInput shows:
   - Title: "Select payment amount"
   - Quick Actions: "Quick Actions"
   - Min Button: "Minimum Deposit"
   - Half Button: "Half Price"
   - Full Button: "Full Price"
   - Custom Label: "Custom Amount"
   - Input hint: "Enter amount"
   - Currency: "LE"
   - Payment: "Payment Amount"
   - Remaining: "Remaining Amount"

**Expected:** All text in English (LTR layout)

---

### Test 11: Error Messages Localization
**Goal:** Verify error messages appear in correct language

**Arabic Test:**
1. Language: Arabic
2. Enter amount below minimum: 150 (min 200)
3. Verify error: "المبلغ يجب أن لا يقل عن 200 ج.م"

**English Test:**
1. Language: English
2. Enter amount below minimum: 150 (min 200)
3. Verify error: "Amount must be at least 200 LE"

---

### Test 12: No Hardcoded Strings
**Goal:** Verify localization coverage is complete

**Steps:**
1. Code review: `flexible_payment_input.dart`
   - Search for hardcoded strings
   - Verify all strings use `context.tr()`
   - Expected: 0 hardcoded strings ✅

2. Code review: `booking_page.dart`
   - Check new/modified lines
   - Verify all strings use `context.tr()`
   - Expected: 0 hardcoded strings ✅

3. Run analyzer:
   ```bash
   flutter analyze
   ```
   - No warnings about localization
   - No unused imports

---

## 📊 Test Results Template

```
TEST CASE: [Test Name]
DEVICE: [Brand/Model]
OS: [iOS/Android]
LANGUAGE: [AR/EN]
DATE: [Date Tested]

STEPS PERFORMED:
1. ...
2. ...
3. ...

EXPECTED RESULT:
- ...

ACTUAL RESULT:
- ...

STATUS: ✅ PASS / ❌ FAIL / ⚠️ PARTIAL

NOTES:
- Any observations
- Screenshot attached: [Y/N]
```

---

## 🔍 Edge Cases to Test

### Input Edge Cases
- [ ] Empty amount field
- [ ] Amount with decimal (123.45)
- [ ] Amount as text "abc"
- [ ] Very large number (999999)
- [ ] Negative number (-100)
- [ ] Zero (0)
- [ ] Exactly min amount
- [ ] Exactly max amount

### State Edge Cases
- [ ] Select all slots then deselect all
- [ ] Rapid button clicking
- [ ] Switch language mid-input
- [ ] Background/Resume during input
- [ ] Multiple time slot changes
- [ ] Screen rotation during input

### Network Edge Cases
- [ ] Slow network during confirmation
- [ ] Network timeout during payment
- [ ] Payment failure with flexible amount
- [ ] Successful payment with flexible amount

---

## 📋 Regression Testing

### Existing Features Should Still Work
- [ ] Normal time slot selection
- [ ] Monthly/daily booking view
- [ ] Payment method selection
- [ ] Booking confirmation
- [ ] Payment processing
- [ ] Booking history
- [ ] User profile
- [ ] All navigation flows

---

## 🎨 Visual Regression Testing

### Color Verification
- [ ] Border: Green when amount valid
- [ ] Border: Red when amount invalid
- [ ] Quick buttons: Wasabi when selected
- [ ] Quick buttons: White when unselected
- [ ] Error icon: EgyptianEarth color
- [ ] Remaining amount: Orange when > 0
- [ ] Remaining amount: Green when = 0

### Layout Verification
- [ ] Buttons aligned properly
- [ ] Text wrapping correct
- [ ] Spacing consistent
- [ ] Input field appropriate size
- [ ] Error message display
- [ ] Summary section alignment

---

## ✅ Final Verification Checklist

Before marking as **DONE**:

**Functionality**
- [ ] All 12 test scenarios pass
- [ ] No hardcoded strings found
- [ ] All translation keys present
- [ ] Edge cases handled
- [ ] Validation working correctly

**Localization**
- [ ] Arabic displays correctly
- [ ] English displays correctly
- [ ] Error messages localized
- [ ] Currency symbols correct
- [ ] RTL/LTR layouts work

**Code Quality**
- [ ] No analyzer warnings
- [ ] No syntax errors
- [ ] Proper imports
- [ ] Consistent formatting
- [ ] Proper state management

**UI/UX**
- [ ] Colors applied correctly
- [ ] Touch targets appropriate
- [ ] Visual feedback clear
- [ ] Error messages helpful
- [ ] Layout responsive

---

## 📞 Issues & Notes

### Known Limitations
- None identified at this time

### Recommendations
1. Monitor payment conversion with flexible amounts
2. Gather user feedback on quick button usefulness
3. Track average payment amounts vs. minimum required
4. Consider A/B testing different quick amounts

### Future Improvements
- [ ] Add payment history showing flexible amounts
- [ ] Add smart suggestion based on user patterns
- [ ] Add payment plan options
- [ ] Add discount on full payment vs. deposit
- [ ] Add tip/additional amount option

---

**Testing Status:** 🟢 **READY TO TEST**

Start with Test 1 and work through sequentially. Report any failures with detailed steps for reproduction.

