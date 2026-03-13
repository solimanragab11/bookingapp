# Hanzbthalk — Sign-Up Feature

**Clean Architecture · Cubit/BLoC · Firebase Phone Auth · Dark Cinematic UI**

---

## 📁 Folder Structure

```
lib/features/auth/signup/
├── signup.dart                       ← Barrel export (import this)
├── cubit/
│   ├── signup_cubit.dart             ← Business logic + Firebase calls
│   └── signup_state.dart             ← All state definitions (part of)
├── core/
│   └── hanzbthalk_theme.dart         ← Brand tokens (copy to lib/core/theme/)
└── ui/
    ├── screens/
    │   └── signup_screen.dart        ← Root screen widget
    └── widgets/
        └── signup_widgets.dart       ← All reusable components
```

---

## 🎨 Design System

| Token            | Value          | Description                    |
|------------------|----------------|--------------------------------|
| `wasabiGreen`    | `#7A9A3F`      | Primary / CTA                  |
| `deepNoir`       | `#0D0D0D`      | Background (dark mode)         |
| `egyptianEarth`  | `#C8773A`      | Accent / glow                  |
| `offWhite`       | `#F0EDE8`      | Primary text                   |
| Font (titles)    | `Aref Ruqaa`   | Google Fonts — brand identity  |
| Font (body)      | `Cairo`        | Readability / Arabic support   |

---

## 📦 pubspec.yaml dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_bloc: ^8.1.5
  bloc: ^8.1.4
  equatable: ^2.0.5

  # Firebase
  firebase_core: ^2.31.1
  firebase_auth: ^4.19.6

  # Your project package (localization + extensions)
  remaking_booking_app_trail2:
    path: ../remaking_booking_app_trail2   # adjust to your path

  # URL launcher (for Terms link)
  url_launcher: ^6.3.0

flutter:
  fonts:
    - family: ArefRuqaa
      fonts:
        - asset: assets/fonts/ArefRuqaa-Regular.ttf
        - asset: assets/fonts/ArefRuqaa-Bold.ttf
          weight: 700
    - family: Cairo
      fonts:
        - asset: assets/fonts/Cairo-Regular.ttf
        - asset: assets/fonts/Cairo-Bold.ttf
          weight: 700
```

> **Tip:** You can also use `google_fonts` package and replace font references with
> `GoogleFonts.arefRuqaa()` and `GoogleFonts.cairo()` to avoid bundling font files.

---

## 🚀 Usage

### 1. Register the route

```dart
// Using GoRouter example:
GoRoute(
  path: '/signup',
  builder: (context, state) => BlocProvider(
    create: (_) => SignupCubit(),
    child: const SignupScreen(),
  ),
),
```

### 2. Handle success navigation

In `SignupScreen._handleStateListener`, replace the TODO comment:

```dart
if (state is SignupSuccess) {
  context.go('/home'); // or your onboarding route
}
```

### 3. Enable URL launcher for Terms

Uncomment in `TermsCheckbox._launchTerms`:

```dart
await launchUrl(
  Uri.parse('https://booking-68265.web.app/'),
  mode: LaunchMode.externalApplication,
);
```

---

## 🔥 Firebase Setup

1. Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).
2. Enable **Phone Authentication** in Firebase Console → Authentication → Sign-in method.
3. For Android testing, add your SHA-1 fingerprint in Firebase project settings.
4. For iOS, enable Push Notifications capability and add APNs key in Firebase.

---

## 🧪 State Flow Diagram

```
SignupInitial (termsAccepted: false)
    │
    ├─ toggleTerms(true) → SignupInitial (termsAccepted: true)
    │
    └─ sendOtp(phone)
           │
           ├─ [invalid phone/terms] → SignupError (phoneValidation)
           │
           └─ [valid] → SignupSendingOtp
                             │
                             ├─ [Firebase error] → SignupError (firebaseSend)
                             │
                             ├─ [auto-verified] → SignupVerifyingOtp → SignupSuccess
                             │
                             └─ [codeSent] → SignupOtpSent
                                                  │
                                                  └─ verifyOtp(code)
                                                        │
                                                        ├─ [wrong code] → SignupError (otpInvalid)
                                                        ├─ [expired]    → SignupError (otpExpired)
                                                        └─ [correct]    → SignupVerifyingOtp → SignupSuccess
```

---

## 📱 Egyptian Phone Validation

Accepted formats:
- `01012345678` (local 11-digit)
- `01112345678`
- `01212345678`
- `01512345678`
- `+201012345678` (E.164)

Converted internally to E.164 (`+201XXXXXXXXX`) before Firebase call.

---

*Built for Hanzbthalk — Book. Play. Experience.* 🎯
