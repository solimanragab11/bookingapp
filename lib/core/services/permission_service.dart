import 'package:hanzbthalk/core/models/user_model.dart';

class PermissionService {
  static bool can(UserModel user, String permission) {
    if (user.userRole == 'admin') return true;

    if (user.userRole == 'owner') return true;

    if (user.userRole == 'employee') {
      return user.permissions[permission] == true;
    }

    return false;
  }
}
