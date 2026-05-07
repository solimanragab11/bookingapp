import 'package:equatable/equatable.dart';
import 'package:remaking_booking_app_trail2/core/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

// في ملف auth_Wrapper_states.dart
class AuthSuccess extends AuthState {
  final UserModel user;
  final String role;

  const AuthSuccess({required this.user, required this.role});

  // ضيف دي ضروري جداً
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthSuccess &&
          runtimeType == other.runtimeType &&
          user.id == other.user.id && // بنقارن بالـ ID
          role == other.role;

  @override
  int get hashCode => user.id.hashCode ^ role.hashCode;
}

class AuthFailure extends AuthState {
  final String messageKey;

  const AuthFailure(this.messageKey);

  @override
  List<Object?> get props => [messageKey];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}
