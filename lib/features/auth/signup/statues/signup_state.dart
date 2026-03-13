abstract class SignUpState {
  const SignUpState();
}

class SignUpInitial extends SignUpState {}

class SignUpLoading extends SignUpState {}

// الحالة دي مهمة جداً يا عمي السولي عشان نفتح شاشة الـ OTP
class CodeSentState extends SignUpState {}

class SignUpSuccess extends SignUpState {
  final String username; // غيرناها لـ username عشان تمشي مع الـ UserModel بتاعك
  const SignUpSuccess(this.username);
}

class SignUpError extends SignUpState {
  final String errorMessage;
  const SignUpError(this.errorMessage);
}
