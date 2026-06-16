import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/style_manger/text_style_mangare.dart';
import 'package:hanzbthalk/core/routes/routes.dart';

class MapFilterBottomSheet extends StatefulWidget {
  final LatLng? initialLocation;
  final double? initialRadiusKm;
  final String? initialAddress;
  final DateTime? initialDate;
  final String? initialStartHour;
  final String? initialEndHour;

  const MapFilterBottomSheet({
    super.key,
    this.initialLocation,
    this.initialRadiusKm,
    this.initialAddress,
    this.initialDate,
    this.initialStartHour,
    this.initialEndHour,
  });

  static Future<Map<String, dynamic>?> show({
    required BuildContext context,
    LatLng? initialLocation,
    double? initialRadiusKm,
    String? initialAddress,
    DateTime? initialDate,
    String? initialStartHour,
    String? initialEndHour,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MapFilterBottomSheet(
        initialLocation: initialLocation,
        initialRadiusKm: initialRadiusKm,
        initialAddress: initialAddress,
        initialDate: initialDate,
        initialStartHour: initialStartHour,
        initialEndHour: initialEndHour,
      ),
    );
  }

  @override
  State<MapFilterBottomSheet> createState() => _MapFilterBottomSheetState();
}

class _MapFilterBottomSheetState extends State<MapFilterBottomSheet> {
  LatLng? _selectedLocation;
  String? _selectedAddress;
  double _radiusKm = 10.0;
  DateTime? _selectedDate;
  String _startHour = '18:00';
  int _durationHours = 2;
  String _endHour = '20:00';

  final List<String> _hoursList = List.generate(24, (i) => "${i.toString().padLeft(2, '0')}:00");

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _selectedAddress = widget.initialAddress;
    _radiusKm = widget.initialRadiusKm ?? 10.0;
    _selectedDate = widget.initialDate;
    _startHour = widget.initialStartHour ?? '18:00';
    _endHour = widget.initialEndHour ?? '20:00';

    try {
      int sH = int.parse(_startHour.split(':')[0]);
      int eH = int.parse(_endHour.split(':')[0]);
      if (eH > sH) {
        _durationHours = eH - sH;
      } else {
        _durationHours = 2;
      }
    } catch (_) {
      _durationHours = 2;
    }
  }

  void _updateEndHour() {
    try {
      int sH = int.parse(_startHour.split(':')[0]);
      int eH = sH + _durationHours;
      if (eH > 24) eH = 24;
      _endHour = "${eH.toString().padLeft(2, '0')}:00";
    } catch (_) {
      _endHour = '20:00';
    }
  }

  Future<void> _pickLocationOnMap() async {
    final result = await Navigator.pushNamed(context, Routes.mapSelection);
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _selectedLocation = result['location'] as LatLng?;
        _selectedAddress = result['address'] as String?;
      });
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 9)), // fits freeTimeSlots next 10 days
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: ColorManager.egyptianEarth,
              onPrimary: Colors.white,
              surface: ColorManager.cardSurface,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: ColorManager.noirDeVigne,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatTo12Hour(String hour24) {
    try {
      final parts = hour24.split(':');
      int h = int.parse(parts[0]);
      final String period = h >= 12 ? 'PM' : 'AM';
      int h12 = h % 12;
      if (h12 == 0) h12 = 12;
      return "$h12:00 $period";
    } catch (_) {
      return hour24;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: ColorManager.cardSurface.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: const Border(
            top: BorderSide(color: ColorManager.emeraldGreen, width: 1.5),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorManager.emeraldGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                context.tr('filterPlacesTitle', defaultValue: 'Area & Time Filters'),
                style: TextStyleMangare.headingStyle.copyWith(
                  fontSize: 22,
                  color: ColorManager.creasedKhaki,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                context.tr('filterPlacesSubtitle', defaultValue: 'Find places matching your specific needs'),
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
              ),
              const Divider(color: Colors.white10, height: 25),

              // Section 1: Geographic Area Selection
              Text(
                context.tr('selectAreaLabel', defaultValue: '📍 Where are you looking?'),
                style: const TextStyle(
                  color: ColorManager.wasabi,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickLocationOnMap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: ColorManager.noirDeVigne,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: ColorManager.emeraldGreen, width: 1.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.map_rounded, color: ColorManager.egyptianEarth),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedAddress ?? context.tr('chooseLocationOnMap', defaultValue: 'Choose point on map...'),
                          style: TextStyle(
                            color: _selectedAddress != null ? Colors.white : Colors.white38,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Colors.white38),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Section 2: Radius Slider
              if (_selectedLocation != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('searchRadiusLabel', defaultValue: 'Search Radius'),
                      style: const TextStyle(
                        color: ColorManager.wasabi,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      "${_radiusKm.toStringAsFixed(0)} km",
                      style: const TextStyle(
                        color: ColorManager.egyptianEarth,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: ColorManager.egyptianEarth,
                    inactiveTrackColor: Colors.white12,
                    thumbColor: ColorManager.egyptianEarth,
                    overlayColor: ColorManager.egyptianEarth.withOpacity(0.2),
                    valueIndicatorColor: ColorManager.egyptianEarth,
                    valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                  ),
                  child: Slider(
                    value: _radiusKm,
                    min: 2.0,
                    max: 50.0,
                    divisions: 24,
                    label: "${_radiusKm.toStringAsFixed(0)} km",
                    onChanged: (val) {
                      setState(() {
                        _radiusKm = val;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 15),
              ],

              // Section 3: Availability Date Selection
              Text(
                context.tr('targetDateLabel', defaultValue: '📅 When do you want to play?'),
                style: const TextStyle(
                  color: ColorManager.wasabi,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: ColorManager.noirDeVigne,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: _selectedDate != null
                          ? ColorManager.egyptianEarth
                          : ColorManager.emeraldGreen,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, color: ColorManager.egyptianEarth),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _selectedDate != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('EEEE').format(_selectedDate!),
                                    style: const TextStyle(
                                      color: ColorManager.creasedKhaki,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat('d/M/yyyy').format(_selectedDate!),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                context.tr('chooseBookingDate', defaultValue: 'Tap to pick a day...'),
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                      Icon(
                        _selectedDate != null ? Icons.edit_calendar_rounded : Icons.calendar_month_outlined,
                        color: _selectedDate != null ? ColorManager.egyptianEarth : Colors.white38,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Section 4: Target Time Range Dropdowns
              if (_selectedDate != null) ...[
                Text(
                  context.tr('timeRangeLabel', defaultValue: '🕐 What time works for you?'),
                  style: const TextStyle(
                    color: ColorManager.wasabi,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('fromTimeLabel', defaultValue: 'From'),
                            style: const TextStyle(color: ColorManager.wasabi, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: ColorManager.noirDeVigne,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: ColorManager.emeraldGreen.withOpacity(0.5)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _startHour,
                                dropdownColor: ColorManager.noirDeVigne,
                                isExpanded: true,
                                style: const TextStyle(color: Colors.white),
                                items: _hoursList.map((String h) {
                                  return DropdownMenuItem<String>(
                                    value: h,
                                    child: Text(_formatTo12Hour(h)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _startHour = val;
                                      int sH = int.parse(_startHour.split(':')[0]);
                                      int maxRemaining = 24 - sH;
                                      if (_durationHours > maxRemaining) {
                                        _durationHours = maxRemaining > 0 ? maxRemaining : 1;
                                      }
                                      _updateEndHour();
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('durationLabel', defaultValue: 'Duration'),
                            style: const TextStyle(color: ColorManager.wasabi, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: ColorManager.noirDeVigne,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: ColorManager.emeraldGreen.withOpacity(0.5)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _durationHours,
                                dropdownColor: ColorManager.noirDeVigne,
                                isExpanded: true,
                                style: const TextStyle(color: Colors.white),
                                items: () {
                                  int currentStart = 18;
                                  try {
                                    currentStart = int.parse(_startHour.split(':')[0]);
                                  } catch (_) {}
                                  int maxRemaining = 24 - currentStart;
                                  if (maxRemaining < 1) maxRemaining = 1;
                                  return List.generate(maxRemaining, (index) => index + 1).map((int hours) {
                                    return DropdownMenuItem<int>(
                                      value: hours,
                                      child: Text(
                                        "$hours ${hours == 1 ? context.tr('hour_singular') : context.tr('hour_plural')}",
                                      ),
                                    );
                                  }).toList();
                                }(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _durationHours = val;
                                      _updateEndHour();
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
              ],

              // Actions Buttons Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white38),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        // Clear all filters
                        Navigator.pop(context, {
                          'clear': true,
                        });
                      },
                      child: Text(
                        context.tr('clearBtn', defaultValue: 'Clear'),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorManager.egyptianEarth,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        // Apply filters
                        Navigator.pop(context, {
                          'clear': false,
                          'location': _selectedLocation,
                          'radiusKm': _radiusKm,
                          'address': _selectedAddress,
                          'date': _selectedDate,
                          'startHour': _startHour,
                          'endHour': _endHour,
                        });
                      },
                      child: Text(
                        context.tr('searchBtn', defaultValue: 'Search'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
