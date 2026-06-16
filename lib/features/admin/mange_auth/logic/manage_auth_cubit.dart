import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/db/admin_services.dart';
import 'package:hanzbthalk/core/models/user_model.dart';
import 'package:hanzbthalk/features/admin/mange_auth/logic/mange_auth_states.dart';

class ManageAuthCubit extends Cubit<ManageAuthState> {
  final AdminService _adminService;
  Timer? _debounce;
  List<UserModel> _users = [];
  ManageAuthCubit(this._adminService) : super(ManageAuthState.initial());

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  // 🔥 دالة البحث الذكية بالرقم مع Debounce لمنع الضغط على الفايربيز
  void searchUsersByPhone(String phone) {
    if (phone.isEmpty) {
      return;
    }

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      emit(
        state.copyWith(users: [], isLoading: true, errorMessage: () => null),
      );
      try {
        // بنستخدم دالة البحث اللي عندك في الـ Service
        final results = await _adminService.searchUsersByPhone('+2$phone');
        _users = results;

        emit(state.copyWith(users: _users, isLoading: false));
      } catch (e) {
        emit(
          state.copyWith(isLoading: false, errorMessage: () => e.toString()),
        );
      }
    });
  }

  // 👑 دالة لتغيير صلاحية المستخدم (مثلاً تحويله لـ Owner أو Admin)
  Future<void> updateUserRole(String userId, String newRole) async {
    emit(
      state.copyWith(
        isActionLoading: true,
        errorMessage: () => null,
        successMessage: () => null,
      ),
    );
    try {
      if (newRole == 'owner') {
        newRole = 'owner_b';
      }
      await _adminService.updateUserRoleInFirebase(userId, newRole);

      // تحديث اللستة محلياً في الـ UI فوراً عشان الأدمن يشوف التغيير بمجرد النجاح
      // تحديث اللستة محلياً في الـ UI فوراً عن طريق الـ Constructor العادي
      final updatedUsers = state.users.map((user) {
        if (user.id == userId) {
          return UserModel(
            id: user.id,
            username: user.username,
            phoneNumber: user.phoneNumber,
            userRole: newRole, // 🔥 التغيير الجديد اللي الأدمن اختاره بس
            favoraitsPlaces:
                user.favoraitsPlaces, // ✅ بنحافظ على بياناته القديمة
            ownedPlaces: user.ownedPlaces, // ✅ بنحافظ على ملاعبه
            bookedPlaces: user.bookedPlaces, // ✅ بنحافظ على حجوزاته
            offers: user.offers,
            history: user.history,
            points: user.points, // ✅ بنحافظ على نقاطه
          );
        }
        return user;
      }).toList(); // ما تنساش الـ .toList() في الآخر عشان تقفل الـ map صح
      emit(
        state.copyWith(
          users: updatedUsers,
          isActionLoading: false,
          successMessage: () => "User role updated successfully to $newRole!",
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isActionLoading: false,
          errorMessage: () => e.toString(),
        ),
      );
    }
  }

  void clearMessages() {
    emit(state.copyWith(errorMessage: () => null, successMessage: () => null));
  }
}
