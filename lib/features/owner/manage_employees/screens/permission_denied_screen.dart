import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class ManageEmployeesPermissionDenied extends StatelessWidget {
  const ManageEmployeesPermissionDenied({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Denied'),
        backgroundColor: ColorManager.emeraldGreen,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.lock_outline, size: 80, color: Colors.redAccent),
              SizedBox(height: 24),
              Text(
                'You do not have permission to manage employees.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
