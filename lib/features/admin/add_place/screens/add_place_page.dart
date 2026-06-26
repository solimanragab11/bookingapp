import 'dart:io';
import 'dart:ui'; // 🌟 مهم عشان الـ ImageFilter للتمويه (Blur) بتاع الصاروخ
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/core/routes/routes.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/widgets/background.dart';
import 'package:hanzbthalk/core/widgets/snackbar_utils.dart';
import 'package:hanzbthalk/features/admin/add_place/logic/add_place_cubit.dart';
import 'package:hanzbthalk/features/admin/add_place/logic/add_place_state.dart';
import 'package:hanzbthalk/features/admin/add_place/widgets/app_bar.dart';
import 'package:hanzbthalk/features/admin/add_place/widgets/add_place_stepper_controls.dart';
import 'package:hanzbthalk/features/admin/add_place/widgets/basic_info_step.dart';
import 'package:hanzbthalk/features/admin/add_place/widgets/search_bar/add_place_searchbar.dart';
import 'package:hanzbthalk/features/admin/add_place/widgets/sub_places_step.dart';
import 'package:hanzbthalk/features/admin/add_place/widgets/media_step.dart';
import 'package:hanzbthalk/features/admin/add_place/widgets/loading_overlay.dart';

class AddPlaceScreen extends StatefulWidget {
  final PlaceModel? placeToEdit; // لو null يبقى إضافة، لو موجود يبقى تعديل
  const AddPlaceScreen({super.key, this.placeToEdit});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  // ─── Stepper ──────────────────────────────────────────────────────────────
  int _currentStep = 0;

  // ─── Step 1 ───────────────────────────────────────────────────────────────
  String? _selectedCategory;
  String? _selectedGovernorate;
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _step1FormKey = GlobalKey<FormState>();

  String _openingTime = '09:00 AM';
  String _closingTime = '12:00 PM';
  bool _isOpen24_7 = false;

  // ─── Step 2 ───────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _subPlaces = [];
  final _minChargeController = TextEditingController();
  LatLng? _selectedLocation;
  String? _selectedAddress;

  // ─── Step 3 ───────────────────────────────────────────────────────────────
  final List<dynamic> _mainImages = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _minChargeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // ─── Step 1 Auto-fill ─────────────────
    _nameController.text = widget.placeToEdit?.name ?? "";
    _descController.text = widget.placeToEdit?.description ?? "";
    _selectedCategory = widget.placeToEdit?.type;
    _selectedGovernorate = widget.placeToEdit?.governorate;
    _openingTime = widget.placeToEdit?.openingTime ?? '09:00 AM';
    _closingTime = widget.placeToEdit?.closingTime ?? '11:00 PM';
    _isOpen24_7 = (_openingTime == '00:00 AM' && _closingTime == '00:00 AM');

    // ─── Step 2 Auto-fill ─────────────────
    _minChargeController.text =
        widget.placeToEdit?.minimumCharge?.toString() ?? "";
    _selectedAddress = widget.placeToEdit?.locationUrl;

    if (widget.placeToEdit != null) {
      context.read<AddPlaceCubit>().loadOwnerForEdit(
        widget.placeToEdit!.ownerId,
      );
      _mainImages.addAll(widget.placeToEdit!.images);
      _selectedLocation = LatLng(
        widget.placeToEdit!.latitude,
        widget.placeToEdit!.longitude,
      );

      // جلب الـ SubPlaces الحقيقية من الداتابيز بناءً على subPlacesIds.
      // الناتج هيوصل عن طريق state.subPlaces ويتم تعبية _subPlaces
      // في الـ BlocListener أسفل (_populateSubPlacesFromState).
      context.read<AddPlaceCubit>().loadSubPlacesForEdit(
        widget.placeToEdit!.subPlacesIds,
      );
    }
  }

  // ─── Map ──────────────────────────────────────────────────────────────────

  Future<void> _openMapSelection() async {
    final result = await Navigator.pushNamed<dynamic>(
      context,
      Routes.mapSelection,
    );
    if (!mounted || result is! Map) return;
    final location = result['location'] as LatLng?;
    final rawAddress = result['address'] as String?;
    setState(() {
      _selectedLocation = location;
      _selectedAddress = (rawAddress?.trim().isNotEmpty ?? false)
          ? rawAddress!.trim()
          : null;
    });
  }

  // ─── BlocListener: Errors / Success ────────────────────────────────────────

  bool _listenWhen(AddPlaceState prev, AddPlaceState curr) {
    final newError =
        curr.errorMessage != null && curr.errorMessage != prev.errorMessage;
    final newSuccess = curr.isSuccess && !prev.isSuccess;
    return newError || newSuccess;
  }

  void _handleCubitListener(BuildContext context, AddPlaceState state) {
    if (state.isSuccess) {
      SnackBarUtils.showSuccess(context, 'Success! Place saved successfully.');

      context.read<AddPlaceCubit>().resetStatusFlags();
      Navigator.pop(context);
    }

    if (state.errorMessage != null) {
      SnackBarUtils.showError(context, state.errorMessage!);

      context.read<AddPlaceCubit>().resetStatusFlags();
    }
  }

  // ─── BlocListener: Populate _subPlaces once loaded (Edit mode) ─────────────

  bool _subPlacesListenWhen(AddPlaceState prev, AddPlaceState curr) {
    return prev.subPlaces != curr.subPlaces && curr.subPlaces.isNotEmpty;
  }

  void _populateSubPlacesFromState(BuildContext context, AddPlaceState state) {
    setState(() {
      _subPlaces.clear();
      final subPlaceUrls = <String>{};
      for (final sp in state.subPlaces) {
        _subPlaces.add({
          'playersNumber': sp.playersNumber.toString(),
          'price': sp.pricePerHour.toString(),
          'image': sp.imageUrl, // ممكن تكون URL أو File path
          'id': sp.id,
        });
        if (sp.imageUrl.isNotEmpty) {
          subPlaceUrls.add(sp.imageUrl);
        }
      }
      _mainImages.removeWhere((img) => subPlaceUrls.contains(img.toString()));
    });
  }

  // ─── Step navigation ──────────────────────────────────────────────────────

  Future<void> _onStepContinue() async {
    final isEditMode = widget.placeToEdit != null;
    final cubit = context.read<AddPlaceCubit>();

    // ─── STEP 1: Basic Info & Owner Validation ───
    if (_currentStep == 0) {
      if (!_validateStep1(cubit)) return;
      setState(() => _currentStep++);
      return;
    }

    // ─── STEP 2: SubPlaces & Location Validation ───
    if (_currentStep == 1) {
      if (!_validateStep2()) return;
      setState(() => _currentStep++);
      return;
    }

    // ─── STEP 3: Media & Final Save/Update ───
    if (_currentStep == 2) {
      await _handleFinalStep(isEditMode, cubit);
    }
  }

  bool _validateStep1(AddPlaceCubit cubit) {
    final owner = cubit.state.selectedOwner;
    if (owner == null) {
      SnackBarUtils.showErrorSnackBar(
        context,
        context.tr('Please search and select an owner'),
      );
      return false;
    }

    final isFormValid = _step1FormKey.currentState?.validate() ?? false;
    if (!isFormValid) return false;

    if (_selectedCategory == null) {
      SnackBarUtils.showErrorSnackBar(
        context,
        context.tr('Please select a category'),
      );
      return false;
    }

    return true;
  }

  bool _validateStep2() {
    if (_subPlaces.isEmpty) {
      SnackBarUtils.showErrorSnackBar(
        context,
        context.tr('Please add at least one subplace'),
      );
      return false;
    }

    for (int i = 0; i < _subPlaces.length; i++) {
      final sp = _subPlaces[i];
      final price = sp['price']?.toString().trim() ?? '';
      final players = sp['playersNumber']?.toString().trim() ?? '';

      if (price.isEmpty || players.isEmpty) {
        SnackBarUtils.showErrorSnackBar(
          context,
          '${context.tr('Please fill price and players for field')} #${i + 1}',
        );
        return false;
      }
    }

    return true;
  }

  Future<void> _handleFinalStep(bool isEditMode, AddPlaceCubit cubit) async {
    if (_mainImages.isEmpty &&
        (isEditMode && widget.placeToEdit!.images.isEmpty)) {
      SnackBarUtils.showErrorSnackBar(
        context,
        context.tr('Please add at least one main photo'),
      );
      return;
    }

    final owner = cubit.state.selectedOwner;
    if (owner == null) {
      SnackBarUtils.showErrorSnackBar(
        context,
        context.tr('Owner not selected. Please go back to step 1.'),
      );
      setState(() => _currentStep = 0);
      return;
    }

    final finalPlaceData = _buildFinalPlaceData(isEditMode, cubit, owner.id);

    // _subPlaces (raw List<Map>) يتم تمريرها كما هي للـ Cubit/Repo، اللي
    // مسؤول عن بناء SubPlaceModel/SlotsModel عبر subplace_builder.dart
    // والحفاظ على slotsIds الموجودة (في حالة التعديل).
    if (isEditMode) {
      await cubit.updateExistingPlace(finalPlaceData, _subPlaces);
    } else {
      cubit.updatePlace(finalPlaceData);
      await cubit.savePlace(_subPlaces);
    }
  }

  PlaceModel _buildFinalPlaceData(
    bool isEditMode,
    AddPlaceCubit cubit,
    String ownerId,
  ) {
    final opening = _isOpen24_7 ? '00:00 AM' : _openingTime;
    final closing = _isOpen24_7 ? '00:00 AM' : _closingTime;

    return (isEditMode ? widget.placeToEdit! : cubit.state.place).copyWith(
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      type: _selectedCategory ?? '',
      ownerId: ownerId,
      openingTime: opening,
      closingTime: closing,
      latitude:
          _selectedLocation?.latitude ??
          (isEditMode ? widget.placeToEdit!.latitude : 0.0),
      longitude:
          _selectedLocation?.longitude ??
          (isEditMode ? widget.placeToEdit!.longitude : 0.0),
      locationUrl:
          _selectedAddress ??
          (isEditMode ? widget.placeToEdit!.locationUrl : ''),
      images: _mainImages.map((img) {
        if (img is File) return img.path;
        return img.toString();
      }).toList(),
      governorate: _selectedGovernorate ?? 'alexandria',
      minimumCharge: _minChargeController.text.trim().isNotEmpty
          ? double.tryParse(_minChargeController.text.trim())
          : null,
    );
  }

  void _onStepCancel() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  // ─── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorManager.noirDeVigne,
      body: Stack(
        children: [
          BackGround(h: size.height, w: size.width),

          SafeArea(
            child: MultiBlocListener(
              listeners: [
                BlocListener<AddPlaceCubit, AddPlaceState>(
                  listenWhen: _listenWhen,
                  listener: _handleCubitListener,
                ),
                BlocListener<AddPlaceCubit, AddPlaceState>(
                  listenWhen: _subPlacesListenWhen,
                  listener: _populateSubPlacesFromState,
                ),
              ],
              child: Column(
                children: [
                  CustAppBar(
                    width: size.width,
                    onTap: () => context.read<AddPlaceCubit>().deletePlace(
                      widget.placeToEdit!,
                    ),
                  ),
                  const AddPlaceSearchBar(),
                  _buildStepperContainer(context),
                ],
              ),
            ),
          ),

          // الـ LoadingOverlay العادي بتاعك (لو ملوش علاقة بالنسبة المئوية)
          const LoadingOverlay(),

          // 🚀 السهم الصاروخي ينطلق هنا و يغطي الشاشة بالكامل أثناء الرفع!
          BlocBuilder<AddPlaceCubit, AddPlaceState>(
            // بنفلتر الـ build عشان ميتبنيش غير لو فيه تغيير في النسبة المئوية بس
            buildWhen: (previous, current) =>
                previous.uploadProgress != current.uploadProgress,
            builder: (context, state) {
              return RocketArrowUploadOverlay(progress: state.uploadProgress);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepperContainer(BuildContext context) {
    return Expanded(
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: ColorManager.wasabi),
        ),
        child: Stepper(
          physics: const BouncingScrollPhysics(),
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: _onStepContinue,
          onStepCancel: _onStepCancel,
          controlsBuilder: (context, details) => AddPlaceStepperControls(
            details,
            isLastStep: _currentStep == 2,
            onContinue: details.onStepContinue!,
            onCancel: details.onStepCancel,
          ),
          steps: _buildSteps(),
        ),
      ),
    );
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: Text(
          context.tr('step_basic_info'),
          style: const TextStyle(
            color: ColorManager.egyptianEarth,
            fontSize: 12,
          ),
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        content: Form(
          key: _step1FormKey,
          child: BasicInfoStep(
            nameController: _nameController,
            descController: _descController,
            selectedCategory: _selectedCategory,
            onCategoryChanged: (val) => setState(() => _selectedCategory = val),
            selectedGovernorate: _selectedGovernorate,
            onGovernorateChanged: (val) => setState(() => _selectedGovernorate = val),
            openingTime: _openingTime,
            closingTime: _closingTime,
            isOpen24_7: _isOpen24_7,
            onOpeningTimeChanged: (val) => setState(() => _openingTime = val),
            onClosingTimeChanged: (val) => setState(() => _closingTime = val),
            onOpen24_7Changed: (val) => setState(() => _isOpen24_7 = val),
          ),
        ),
      ),
      Step(
        title: Text(
          context.tr('availableFields'),
          style: const TextStyle(
            color: ColorManager.egyptianEarth,
            fontSize: 12,
          ),
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        content: SubPlacesStep(
          selectedCategory: _selectedCategory,
          minChargeController: _minChargeController,
          subPlaces: _subPlaces,
          selectedAddress: _selectedAddress,
          onOpenMapSelection: _openMapSelection,
          onAddSubPlace: () => setState(
            () => _subPlaces.add({
              'playersNumber': '',
              'price': '',
              'image': null,
            }),
          ),
          onRemoveSubPlace: (index) =>
              setState(() => _subPlaces.removeAt(index)),
          onPickImage: (index) async {
            final file = await context
                .read<AddPlaceCubit>()
                .pickSubPlaceImage();
            if (file != null && mounted) {
              setState(() => _subPlaces[index]['image'] = file);
            }
          },
        ),
      ),
      Step(
        title: Text(
          context.tr('uploadMainPhotos'),
          style: const TextStyle(
            color: ColorManager.egyptianEarth,
            fontSize: 12,
          ),
        ),
        isActive: _currentStep >= 2,
        state: StepState.indexed,
        content: MediaStep(
          mainImages: _mainImages,
          onAddImages: () async {
            final images = await context.read<AddPlaceCubit>().pickMainImages();
            if (images.isNotEmpty && mounted) {
              setState(() => _mainImages.addAll(images));
            }
          },
          onRemoveImage: (index) => setState(() => _mainImages.removeAt(index)),
        ),
      ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🚀 Rocket Arrow Overlay Widget & Painter
// ─────────────────────────────────────────────────────────────────────────────

class RocketArrowUploadOverlay extends StatelessWidget {
  final double progress;

  const RocketArrowUploadOverlay({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    if (progress <= 0 || progress >= 100) return const SizedBox.shrink();

    final double screenHeight = MediaQuery.of(context).size.height;
    final Color themeColor = const Color(0xFFB36334);

    final double progressFraction = (progress / 100).clamp(0.0, 1.0);

    final double startPosition = -180.0;
    final double endPosition = screenHeight + 50;

    final double currentBottomPosition =
        startPosition + (progressFraction * (endPosition - startPosition));

    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withOpacity(0.45)),
          ),
        ),

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: (currentBottomPosition + 150).clamp(0.0, screenHeight),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  themeColor.withOpacity(0.5),
                  Colors.orange.withOpacity(0.2),
                  Colors.white.withOpacity(0.05),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.2, 0.8, 1.0],
              ),
            ),
          ),
        ),

        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          bottom: currentBottomPosition,
          left: 0,
          right: 0,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: themeColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    "${progress.toStringAsFixed(0)}% Uploading...",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: 120,
                  height: 150,
                  child: CustomPaint(
                    painter: RocketArrowPainter(color: themeColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class RocketArrowPainter extends CustomPainter {
  final Color color;
  RocketArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    double shaftWidth = size.width * 0.35;
    double headHeight = size.height * 0.35;

    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, headHeight);
    path.lineTo(size.width / 2 + shaftWidth / 2, headHeight);

    path.lineTo(size.width / 2 + shaftWidth / 2, size.height);
    path.lineTo(size.width / 2 - shaftWidth / 2, size.height);
    path.lineTo(size.width / 2 - shaftWidth / 2, headHeight);

    path.lineTo(0, headHeight);
    path.close();

    canvas.drawShadow(path, Colors.black, 6.0, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant RocketArrowPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
