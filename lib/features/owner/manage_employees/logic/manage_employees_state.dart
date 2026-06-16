import 'package:equatable/equatable.dart';
import 'package:hanzbthalk/core/models/user_model.dart';

class ManageEmployeesState extends Equatable {
  final List<UserModel> employees;
  final List<UserModel> searchResults;
  final bool isLoading;
  final bool isActionLoading;
  final String? successMessage;
  final String? errorMessage;

  const ManageEmployeesState({
    required this.employees,
    required this.searchResults,
    required this.isLoading,
    required this.isActionLoading,
    this.successMessage,
    this.errorMessage,
  });

  factory ManageEmployeesState.initial() {
    return const ManageEmployeesState(
      employees: [],
      searchResults: [],
      isLoading: false,
      isActionLoading: false,
      successMessage: null,
      errorMessage: null,
    );
  }

  ManageEmployeesState copyWith({
    List<UserModel>? employees,
    List<UserModel> Function()? searchResults,
    bool? isLoading,
    bool? isActionLoading,
    String? Function()? successMessage,
    String? Function()? errorMessage,
  }) {
    return ManageEmployeesState(
      employees: employees ?? this.employees,
      searchResults: searchResults != null ? searchResults() : this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      successMessage: successMessage != null ? successMessage() : this.successMessage,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        employees,
        searchResults,
        isLoading,
        isActionLoading,
        successMessage,
        errorMessage,
      ];
}
