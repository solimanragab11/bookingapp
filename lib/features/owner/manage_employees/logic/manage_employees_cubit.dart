import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/db/auth_service.dart';
import 'package:hanzbthalk/core/db/firestore_owner_service.dart';
import 'package:hanzbthalk/features/owner/manage_employees/logic/manage_employees_state.dart';

class ManageEmployeesCubit extends Cubit<ManageEmployeesState> {
  final FirestoreOwnerService _ownerService;
  final AuthService _authService;
  Timer? _debounce;
  String? _currentQueryPhone;

  ManageEmployeesCubit(this._ownerService, this._authService)
      : super(ManageEmployeesState.initial());

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  // 1. Load current employees under this owner
  Future<void> loadCurrentEmployees() async {
    debugPrint("[ManageEmployeesCubit] loadCurrentEmployees initiated.");
    emit(state.copyWith(isLoading: true, errorMessage: () => null, successMessage: () => null));
    try {
      final ownerId = await _authService.getCurrentUserId();
      debugPrint("[ManageEmployeesCubit] Current owner ID: $ownerId");
      if (ownerId == null) {
        debugPrint("[ManageEmployeesCubit] Error: Owner not authenticated.");
        emit(state.copyWith(isLoading: false, errorMessage: () => "User not authenticated."));
        return;
      }
      final list = await _ownerService.getEmployeesByOwner(ownerId);
      debugPrint("[ManageEmployeesCubit] Employees loaded successfully. Count: ${list.length}");
      emit(state.copyWith(employees: list, isLoading: false));
    } catch (e) {
      debugPrint("[ManageEmployeesCubit] Error loading employees: $e");
      emit(state.copyWith(isLoading: false, errorMessage: () => e.toString()));
    }
  }

  // 2. Search user by phone number
  void searchUserByPhone(String phone) {
    debugPrint("[ManageEmployeesCubit] searchUserByPhone called with input: '$phone'");
    final cleanPhone = phone.trim().replaceAll(RegExp(r'[\s\-\(\)]+'), '');
    debugPrint("[ManageEmployeesCubit] Cleaned phone: '$cleanPhone'");
    
    if (cleanPhone.isEmpty) {
      debugPrint("[ManageEmployeesCubit] Cleaned phone is empty, clearing searchResults.");
      _currentQueryPhone = null;
      emit(state.copyWith(searchResults: () => [], errorMessage: () => null, isLoading: false));
      return;
    }

    bool shouldSearch = false;
    if (cleanPhone.startsWith('+')) {
      shouldSearch = cleanPhone.length >= 4;
    } else if (cleanPhone.startsWith('00')) {
      shouldSearch = cleanPhone.length >= 5;
    } else if (cleanPhone.startsWith('0')) {
      shouldSearch = cleanPhone.length >= 3;
    } else if (cleanPhone.startsWith('20')) {
      shouldSearch = cleanPhone.length >= 4;
    } else {
      shouldSearch = cleanPhone.length >= 2;
    }

    if (!shouldSearch) {
      debugPrint("[ManageEmployeesCubit] Input too short, clearing searchResults.");
      _currentQueryPhone = null;
      emit(state.copyWith(searchResults: () => [], errorMessage: () => null, isLoading: false));
      return;
    }

    // Format phone for prefix matching
    String formattedPhone = '';
    if (cleanPhone.startsWith('+')) {
      formattedPhone = cleanPhone;
    } else if (cleanPhone.startsWith('00')) {
      formattedPhone = '+${cleanPhone.substring(2)}';
    } else if (cleanPhone.startsWith('0')) {
      formattedPhone = '+20${cleanPhone.substring(1)}';
    } else if (cleanPhone.startsWith('20')) {
      formattedPhone = '+$cleanPhone';
    } else if (cleanPhone.startsWith('1')) {
      formattedPhone = '+20$cleanPhone';
    } else {
      formattedPhone = '+2$cleanPhone';
    }

    debugPrint("[ManageEmployeesCubit] shouldSearch: $shouldSearch, formattedPhone: '$formattedPhone'");

    if (_debounce?.isActive ?? false) {
      debugPrint("[ManageEmployeesCubit] Cancelling active debounce timer.");
      _debounce!.cancel();
    }

    _currentQueryPhone = formattedPhone;

    debugPrint("[ManageEmployeesCubit] Starting 500ms debounce timer for query.");
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      debugPrint("[ManageEmployeesCubit] Debounce finished. Querying Firestore for '$formattedPhone'...");
      emit(state.copyWith(isLoading: true, searchResults: () => [], errorMessage: () => null));
      try {
        final results = await _ownerService.searchUsersByPhone(formattedPhone);
        
        // Race condition check: make sure the search result matches the most recent search query
        if (formattedPhone != _currentQueryPhone) {
          debugPrint("[ManageEmployeesCubit] Query discarded. Expected query: '$_currentQueryPhone', but got: '$formattedPhone'");
          return;
        }

        debugPrint("[ManageEmployeesCubit] Users found: ${results.length}");
        emit(state.copyWith(searchResults: () => results, isLoading: false));
      } catch (e) {
        if (formattedPhone != _currentQueryPhone) return;
        debugPrint("[ManageEmployeesCubit] Error during search: $e");
        emit(state.copyWith(isLoading: false, errorMessage: () => e.toString()));
      }
    });
  }

  // 3. Save or edit employee details
  Future<void> saveEmployee({
    required String employeeId,
    required List<String> assignedPlaceIds,
    required Map<String, bool> permissions,
  }) async {
    debugPrint("[ManageEmployeesCubit] saveEmployee initiated. EmployeeID: $employeeId");
    debugPrint("[ManageEmployeesCubit] AssignedPlaces: $assignedPlaceIds, Permissions: $permissions");
    emit(state.copyWith(isActionLoading: true, errorMessage: () => null, successMessage: () => null));
    try {
      final ownerId = await _authService.getCurrentUserId();
      debugPrint("[ManageEmployeesCubit] Owner ID: $ownerId");
      if (ownerId == null) {
        debugPrint("[ManageEmployeesCubit] Error: Owner not authenticated during save.");
        emit(state.copyWith(isActionLoading: false, errorMessage: () => "User not authenticated."));
        return;
      }

      debugPrint("[ManageEmployeesCubit] Calling updateEmployeeDetails on FirestoreOwnerService...");
      await _ownerService.updateEmployeeDetails(
        employeeId: employeeId,
        ownerId: ownerId,
        role: 'employee',
        assignedPlaceIds: assignedPlaceIds,
        permissions: permissions,
      );

      debugPrint("[ManageEmployeesCubit] Employee saved successfully.");
      emit(state.copyWith(
        isActionLoading: false,
        successMessage: () => "employeeSavedSuccess",
        searchResults: () => [], // clear search results after successful addition
      ));

      debugPrint("[ManageEmployeesCubit] Reloading employee list...");
      // Reload the employees list
      await loadCurrentEmployees();
    } catch (e) {
      debugPrint("[ManageEmployeesCubit] Error saving employee: $e");
      emit(state.copyWith(isActionLoading: false, errorMessage: () => e.toString()));
    }
  }

  // 4. Remove / demote employee back to regular user
  Future<void> removeEmployee(String employeeId) async {
    debugPrint("[ManageEmployeesCubit] removeEmployee initiated. Demoting EmployeeID: $employeeId to role 'user'.");
    emit(state.copyWith(isActionLoading: true, errorMessage: () => null, successMessage: () => null));
    try {
      debugPrint("[ManageEmployeesCubit] Calling updateEmployeeDetails on FirestoreOwnerService for demotion...");
      await _ownerService.updateEmployeeDetails(
        employeeId: employeeId,
        ownerId: null,
        role: 'user',
        assignedPlaceIds: const [],
        permissions: const {},
      );

      debugPrint("[ManageEmployeesCubit] Employee removed/demoted successfully.");
      emit(state.copyWith(
        isActionLoading: false,
        successMessage: () => "employeeRemovedSuccess",
      ));

      debugPrint("[ManageEmployeesCubit] Reloading employee list...");
      // Reload the employees list
      await loadCurrentEmployees();
    } catch (e) {
      debugPrint("[ManageEmployeesCubit] Error removing employee: $e");
      emit(state.copyWith(isActionLoading: false, errorMessage: () => e.toString()));
    }
  }

  void clearMessages() {
    emit(state.copyWith(errorMessage: () => null, successMessage: () => null));
  }
}
