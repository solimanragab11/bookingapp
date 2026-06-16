import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/models/user_model.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class UserAuthCard extends StatelessWidget {
  final UserModel user;
  final bool isActionLoading;
  final ValueChanged<String?> onRoleChanged;

  const UserAuthCard({
    super.key,
    required this.user,
    required this.isActionLoading,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorManager.wasabi.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: ColorManager.creasedKhaki.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // الأفاتار الدائري
          CircleAvatar(
            radius: 24,
            backgroundColor: ColorManager.wasabi.withOpacity(0.15),
            child: Text(
              user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
              style: TextStyle(
                color: ColorManager.egyptianEarth,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // بيانات المستخدم والـ Role الحالي
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: TextStyle(
                    color: ColorManager.egyptianEarth,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.phoneNumber,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: ColorManager.creasedKhaki.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user.userRole.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      color: ColorManager.egyptianEarth,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // الـ Dropdown لتغيير الـ Role
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorManager.wasabi.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: ['owner', 'user', 'admin'].contains(user.userRole)
                    ? user.userRole
                    : 'user',
                icon: Icon(Icons.arrow_drop_down, color: ColorManager.wasabi),
                style: TextStyle(
                  color: ColorManager.egyptianEarth,
                  fontWeight: FontWeight.w600,
                ),
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('user')),
                  DropdownMenuItem(value: 'owner', child: Text('Owner')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: isActionLoading ? null : onRoleChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
