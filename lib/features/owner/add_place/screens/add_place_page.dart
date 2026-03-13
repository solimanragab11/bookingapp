import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/widgets/background.dart';
import 'package:remaking_booking_app_trail2/core/widgets/show_success_dialog.dart';
import 'package:remaking_booking_app_trail2/core/widgets/snackbar_utils.dart';
import 'package:remaking_booking_app_trail2/features/owner/add_place/logic/manage_place_cubit/manage_place_cubit.dart';
import 'package:remaking_booking_app_trail2/features/owner/add_place/logic/manage_place_cubit/manage_place_state.dart';
import 'package:remaking_booking_app_trail2/features/owner/add_place/widgets/app_bar.dart';
import 'package:remaking_booking_app_trail2/features/owner/add_place/widgets/add_place_stepper_controls.dart';
import 'package:remaking_booking_app_trail2/features/owner/add_place/widgets/basic_info_step.dart';
import 'package:remaking_booking_app_trail2/features/owner/add_place/widgets/sub_places_step.dart';
import 'package:remaking_booking_app_trail2/features/owner/add_place/widgets/media_step.dart';
import 'package:remaking_booking_app_trail2/features/owner/add_place/widgets/loading_overlay.dart';

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  int _currentStep = 0;
  String? _selectedCategory;
  final List<Map<String, dynamic>> _subPlaces = [];
  final List<File> _mainImages = [];

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _minChargeController = TextEditingController();
  LatLng? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorManager.noirDeVigne,
      body: Stack(
        children: [
          BackGround(h: size.height, w: size.width),
          SafeArea(
            child: BlocListener<ManagePlaceCubit, ManagePlaceState>(
              listener: (context, state) {
                if (state.isSuccess) showSuccessDialog(context);
                if (state.errorMessage != null) {
                  SnackBarUtils.showErrorSnackBar(context, state.errorMessage!);
                }
              },
              child: Column(
                children: [
                  CustAppBar(width: size.width),
                  Expanded(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: ColorManager.wasabi,
                        ),
                      ),
                      child: Stepper(
                        physics: const BouncingScrollPhysics(),
                        type: StepperType.vertical,
                        currentStep: _currentStep,
                        onStepContinue: () async {
                          if (_currentStep < 2) {
                            setState(() => _currentStep++);
                          } else {
                            await context.read<ManagePlaceCubit>().submitPlaceData(
                                  name: _nameController.text,
                                  desc: _descController.text,
                                  category: _selectedCategory,
                                  subPlacesRaw: _subPlaces,
                                  minCharge: double.tryParse(
                                        _minChargeController.text,
                                      ) ??
                                      0.0,
                                  mainImages: _mainImages,
                                  location: _selectedLocation,
                                );
                          }
                        },
                        onStepCancel: () => setState(
                          () => _currentStep > 0 ? _currentStep-- : null,
                        ),
                        controlsBuilder: (context, details) =>
                            AddPlaceStepperControls(
                              details,
                              isLastStep: _currentStep == 2,
                              onContinue: details.onStepContinue!,
                              onCancel: details.onStepCancel,
                            ),
                        steps: _getSteps(context, size),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const LoadingOverlay(),
        ],
      ),
    );
  }

  List<Step> _getSteps(BuildContext context, Size size) {
    return [
      Step(
        title: Text(
          context.tr('step_basic_info'),
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        isActive: _currentStep >= 0,
        content: BasicInfoStep(
          nameController: _nameController,
          descController: _descController,
          selectedCategory: _selectedCategory,
          onCategoryChanged: (val) {
            setState(() => _selectedCategory = val);
          },
        ),
      ),
      Step(
        title: Text(
          context.tr('availableFields'),
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        isActive: _currentStep >= 1,
        content: SubPlacesStep(
          selectedCategory: _selectedCategory,
          minChargeController: _minChargeController,
          subPlaces: _subPlaces,
          selectedLocation: _selectedLocation,
          onLocationSelected: (loc) {
            setState(() => _selectedLocation = loc);
          },
          onAddSubPlace: () => setState(
            () => _subPlaces.add({'size:': '', 'price': '', 'image': null}),
          ),
          onRemoveSubPlace: (index) =>
              setState(() => _subPlaces.removeAt(index)),
          onPickImage: (index) async {
            final file = await context
                .read<ManagePlaceCubit>()
                .pickSubPlaceImage();
            if (file != null) {
              setState(() => _subPlaces[index]['image'] = file);
            }
          },
        ),
      ),
      Step(
        title: Text(
          context.tr('uploadMainPhotos'),
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        isActive: _currentStep >= 2,
        content: MediaStep(
          mainImages: _mainImages,
          onAddImages: () async {
            final images =
                await context.read<ManagePlaceCubit>().pickMainImages();
            if (images.isNotEmpty) {
              setState(() => _mainImages.addAll(images));
            }
          },
          onRemoveImage: (index) =>
              setState(() => _mainImages.removeAt(index)),
        ),
      ),
    ];
  }

  // باقي الميثودز الخاصة بالشاشة تم نقلها إلى ويدجتات منفصلة
}
