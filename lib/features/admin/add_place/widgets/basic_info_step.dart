import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/features/admin/add_place/widgets/add_place_text_field.dart';

class BasicInfoStep extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descController;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;

  final String? selectedGovernorate;
  final ValueChanged<String?> onGovernorateChanged;

  final String openingTime;
  final String closingTime;
  final bool isOpen24_7;
  final ValueChanged<String> onOpeningTimeChanged;
  final ValueChanged<String> onClosingTimeChanged;
  final ValueChanged<bool> onOpen24_7Changed;

  const BasicInfoStep({
    super.key,
    required this.nameController,
    required this.descController,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.selectedGovernorate,
    required this.onGovernorateChanged,
    required this.openingTime,
    required this.closingTime,
    required this.isOpen24_7,
    required this.onOpeningTimeChanged,
    required this.onClosingTimeChanged,
    required this.onOpen24_7Changed,
  });

  // ─── Time picker ────────────────────────────────────────────────────────────

  Future<void> _pickTime({
    required BuildContext context,
    required String current,
    required ValueChanged<String> onPicked,
  }) async {
    final parts = current.split(':');
    final hourMinute = parts.length == 2 ? parts[1].split(' ') : null;
    final isPm =
        hourMinute != null &&
        hourMinute.length == 2 &&
        hourMinute[1].toUpperCase() == 'PM';
    int hour = parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 9) : 9;
    int minute = hourMinute != null ? (int.tryParse(hourMinute[0]) ?? 0) : 0;
    if (isPm && hour != 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: ColorManager.wasabi,
            onPrimary: Colors.black,
            surface: ColorManager.cardSurface,
            onSurface: ColorManager.creasedKhaki,
          ),
          dialogBackgroundColor: ColorManager.noirDeVigne,
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: ColorManager.wasabi),
          ),
        ),
        child: child!,
      ),
    );

    if (picked == null) return;
    onPicked(picked.format(context));
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        AddPlaceTextField(
          label: context.tr('fullName'),
          controller: nameController,
          icon: Icons.store,
        ),
        SizedBox(height: size.height * 0.02),
        AddPlaceTextField(
          label: context.tr('description'),
          controller: descController,
          icon: Icons.info_outline,
          maxLines: 3,
        ),
        SizedBox(height: size.height * 0.02),
        _buildCategoryDropdown(context),
        SizedBox(height: size.height * 0.02),
        _buildGovernorateDropdown(context),
        SizedBox(height: size.height * 0.02),

        // ── 24/7 toggle ─────────────────────────────────────────────────────
        _build24_7Toggle(context),
        SizedBox(height: size.height * 0.015),

        // ── Time pickers — hidden when 24/7 is on ───────────────────────────
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: isOpen24_7
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: Row(
            children: [
              Expanded(
                child: _TimeTile(
                  label: context.tr('openingTime'),
                  time: openingTime,
                  icon: Icons.wb_sunny_outlined,
                  onTap: () => _pickTime(
                    context: context,
                    current: openingTime,
                    onPicked: onOpeningTimeChanged,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimeTile(
                  label: context.tr('closingTime'),
                  time: closingTime,
                  icon: Icons.nights_stay_outlined,
                  onTap: () => _pickTime(
                    context: context,
                    current: closingTime,
                    onPicked: onClosingTimeChanged,
                  ),
                ),
              ),
            ],
          ),
          // Empty box replaces the row when 24/7 is active
          secondChild: const SizedBox.shrink(),
        ),

        SizedBox(height: size.height * 0.01),
      ],
    );
  }

  // ─── 24/7 toggle tile ───────────────────────────────────────────────────────

  Widget _build24_7Toggle(BuildContext context) {
    return GestureDetector(
      onTap: () => onOpen24_7Changed(!isOpen24_7),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isOpen24_7
              ? ColorManager.wasabi.withOpacity(0.12)
              : ColorManager.cardSurface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isOpen24_7 ? ColorManager.wasabi : ColorManager.emeraldGreen,
            width: isOpen24_7 ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.all_inclusive,
              color: isOpen24_7
                  ? ColorManager.wasabi
                  : ColorManager.egyptianEarth,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.tr('open24_7'),
                    style: TextStyle(
                      color: isOpen24_7
                          ? ColorManager.wasabi
                          : ColorManager.creasedKhaki,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    context.tr('open24_7Subtitle'),
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
            // Custom animated checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isOpen24_7 ? ColorManager.wasabi : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isOpen24_7 ? ColorManager.wasabi : Colors.white38,
                  width: 2,
                ),
              ),
              child: isOpen24_7
                  ? const Icon(Icons.check, size: 16, color: Colors.black)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Category dropdown ──────────────────────────────────────────────────────

  Widget _buildCategoryDropdown(BuildContext context) {
    final Map<String, String> categories = {
      'padel': context.tr('Padel'),
      'football': context.tr('Football'),
      'playstation': context.tr('PlayStation'),
      'cafe': context.tr('Cafe'),
    };

    return DropdownButtonFormField<String>(
      dropdownColor: ColorManager.cardSurface,
      style: const TextStyle(color: ColorManager.creasedKhaki),
      decoration: InputDecoration(
        labelText: context.tr('category'),
        labelStyle: const TextStyle(color: ColorManager.wasabi),
        prefixIcon: const Icon(
          Icons.category,
          color: ColorManager.egyptianEarth,
        ),
        filled: true,
        fillColor: ColorManager.cardSurface.withOpacity(0.8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: ColorManager.emeraldGreen),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: ColorManager.egyptianEarth,
            width: 2,
          ),
        ),
      ),
      value: selectedCategory,
      items: categories.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: onCategoryChanged,
      validator: (value) => value == null ? context.tr('fieldRequired') : null,
    );
  } // 🎯 ده القوس اللي كان ناقص هنا!

  // ─── Governorate dropdown ───────────────────────────────────────────────────

  Widget _buildGovernorateDropdown(BuildContext context) {
    final Map<String, String> governorates = {
      'alexandria': context.tr('governorate_alexandria'),
      'Damanhour': context.tr('governorate_Damanhour'),
      'Beni Suef': context.tr('governorate_Beni Suef'),
    };

    return DropdownButtonFormField<String>(
      dropdownColor: ColorManager.cardSurface,
      style: const TextStyle(color: ColorManager.creasedKhaki),
      decoration: InputDecoration(
        labelText: context.tr('select_governorate'),
        labelStyle: const TextStyle(color: ColorManager.wasabi),
        prefixIcon: const Icon(
          Icons.location_city_rounded,
          color: ColorManager.egyptianEarth,
        ),
        filled: true,
        fillColor: ColorManager.cardSurface.withOpacity(0.8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: ColorManager.emeraldGreen),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: ColorManager.egyptianEarth,
            width: 2,
          ),
        ),
      ),
      value: selectedGovernorate,
      items: governorates.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: onGovernorateChanged,
      validator: (value) => value == null ? context.tr('fieldRequired') : null,
    );
  }
}

// ─── Time tile ─────────────────────────────────────────────────────────────────

class _TimeTile extends StatelessWidget {
  final String label;
  final String time;
  final IconData icon;
  final VoidCallback onTap;

  const _TimeTile({
    required this.label,
    required this.time,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: ColorManager.cardSurface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: ColorManager.emeraldGreen),
        ),
        child: Row(
          children: [
            Icon(icon, color: ColorManager.egyptianEarth, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: ColorManager.wasabi,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: const TextStyle(
                      color: ColorManager.creasedKhaki,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.access_time, color: ColorManager.wasabi, size: 16),
          ],
        ),
      ),
    );
  }
}
