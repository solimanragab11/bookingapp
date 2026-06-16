import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/core/models/user_model.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class EditEmployeeDialog extends StatefulWidget {
  final UserModel user;
  final List<PlaceModel> places;
  final Function({
    required List<String> assignedPlaceIds,
    required Map<String, bool> permissions,
  })
  onSave;
  final VoidCallback? onDelete;

  const EditEmployeeDialog({
    super.key,
    required this.user,
    required this.places,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<EditEmployeeDialog> createState() => _EditEmployeeDialogState();
}

class _EditEmployeeDialogState extends State<EditEmployeeDialog> {
  final List<String> _selectedPlaceIds = [];
  final Map<String, bool> _permissions = {
    "viewBookings": true,
    "createManualBooking": false,
    "cancelBooking": false,
    "manageAvailability": false,
    "editPlaceInfo": false,
    "viewAnalytics": false,
    "manageEmployees": false,
    "managePlaces": false,
  };

  @override
  void initState() {
    super.initState();
    // Pre-populate fields if editing an existing employee
    if (widget.user.userRole == 'employee') {
      _selectedPlaceIds.addAll(widget.user.assignedPlaceIds);
      _permissions.addAll(widget.user.permissions);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManager.noirDeVigne,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: ColorManager.emeraldGreen, width: 1.5),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user.userRole == 'employee'
                    ? context.tr(
                        'manageEmployeesTitle',
                        defaultValue: 'Edit Employee',
                      )
                    : context.tr(
                        'addEmployeeTitle',
                        defaultValue: 'Add Employee',
                      ),
                style: const TextStyle(
                  color: ColorManager.wasabi,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.user.username} (${widget.user.phoneNumber})',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const Divider(color: Colors.white10, height: 24),

              // Permissions section
              Text(
                context.tr('permissions', defaultValue: 'Permissions'),
                style: const TextStyle(
                  color: ColorManager.creasedKhaki,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._permissions.keys.map((perm) {
                return CheckboxListTile(
                  title: Text(
                    context.tr(perm, defaultValue: perm),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  value: _permissions[perm],
                  activeColor: ColorManager.wasabi,
                  checkColor: Colors.black,
                  dense: true,
                  onChanged: (val) {
                    setState(() {
                      _permissions[perm] = val ?? false;
                    });
                  },
                );
              }),

              const Divider(color: Colors.white10, height: 24),

              // Assigned Places section
              Text(
                context.tr(
                  'edit_employee_dialog_assigned_places',
                  defaultValue: 'Assigned Places',
                ),
                style: const TextStyle(
                  color: ColorManager.creasedKhaki,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (widget.places.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    context.tr(
                      'edit_employee_dialog.no_places',
                      defaultValue: 'No places available to assign.',
                    ),
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                )
              else
                ...widget.places.map((place) {
                  final isChecked = _selectedPlaceIds.contains(place.id);
                  return CheckboxListTile(
                    title: Text(
                      place.name,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    value: isChecked,
                    activeColor: ColorManager.wasabi,
                    checkColor: Colors.black,
                    dense: true,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedPlaceIds.add(place.id);
                        } else {
                          _selectedPlaceIds.remove(place.id);
                        }
                      });
                    },
                  );
                }),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      context.tr('cancel', defaultValue: 'Cancel'),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (widget.user.userRole == 'employee' &&
                      widget.onDelete != null) ...[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      onPressed: widget.onDelete,
                      child: Text(
                        context.tr('remove', defaultValue: 'Remove'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.wasabi,
                    ),
                    onPressed: () {
                      widget.onSave(
                        assignedPlaceIds: _selectedPlaceIds,
                        permissions: _permissions,
                      );
                      Navigator.pop(context);
                    },
                    child: Text(
                      context.tr('save', defaultValue: 'Save'),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
