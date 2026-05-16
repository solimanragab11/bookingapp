import 'package:remaking_booking_app_trail2/core/models/user_model.dart';

class ManageAuthState {
  final List<UserModel> users;
  final bool isLoading;
  final bool isActionLoading; // للتحميل أثناء تغيير الـ Role نفسه
  final String? errorMessage;
  final String? successMessage;

  ManageAuthState({
    required this.users,
    required this.isLoading,
    required this.isActionLoading,
    this.errorMessage,
    this.successMessage,
  });

  factory ManageAuthState.initial() {
    return ManageAuthState(users: [], isLoading: false, isActionLoading: false);
  }

  ManageAuthState copyWith({
    List<UserModel>? users,
    bool? isLoading,
    bool? isActionLoading,
    String? Function()? errorMessage,
    String? Function()? successMessage,
  }) {
    return ManageAuthState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      successMessage: successMessage != null
          ? successMessage()
          : this.successMessage,
    );
  }
}
