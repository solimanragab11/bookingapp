import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/models/subplace.dart';
import 'package:remaking_booking_app_trail2/core/routes/routes.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/widgets/background.dart';
import 'package:remaking_booking_app_trail2/core/widgets/show_success_dialog.dart';
import 'package:remaking_booking_app_trail2/core/widgets/snackbar_utils.dart';
import 'package:remaking_booking_app_trail2/features/admin/add_place/logic/add_place_cubit.dart';
import 'package:remaking_booking_app_trail2/features/admin/add_place/logic/add_place_state.dart';
import 'package:remaking_booking_app_trail2/features/admin/add_place/widgets/add_place_searchbar.dart';
import 'package:remaking_booking_app_trail2/features/admin/add_place/widgets/app_bar.dart';
import 'package:remaking_booking_app_trail2/features/admin/add_place/widgets/add_place_stepper_controls.dart';
import 'package:remaking_booking_app_trail2/features/admin/add_place/widgets/basic_info_step.dart';
import 'package:remaking_booking_app_trail2/features/admin/add_place/widgets/sub_places_step.dart';
import 'package:remaking_booking_app_trail2/features/admin/add_place/widgets/media_step.dart';
import 'package:remaking_booking_app_trail2/features/admin/add_place/widgets/loading_overlay.dart';

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
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _step1FormKey = GlobalKey<FormState>();

  String _openingTime = '09:00 AM';
  String _closingTime = '11:00 PM';
  bool _isOpen24_7 = false;

  // ─── Step 2 ───────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _subPlaces = [];
  final _minChargeController = TextEditingController();
  LatLng? _selectedLocation;
  String? _selectedAddress;

  // ─── Step 3 ───────────────────────────────────────────────────────────────
  final List<File> _mainImages = [];

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
    _openingTime = widget.placeToEdit?.openingTime ?? '09:00 AM';
    _closingTime = widget.placeToEdit?.closingTime ?? '11:00 PM';
    _isOpen24_7 = (_openingTime == '00:00 AM' && _closingTime == '00:00 AM');

    // ─── Step 2 Auto-fill ─────────────────
    _minChargeController.text =
        widget.placeToEdit?.minimumCharge?.toString() ?? "";
    _selectedAddress = widget.placeToEdit?.locationUrl;
    if (widget.placeToEdit != null) {
      _selectedLocation = LatLng(
        widget.placeToEdit!.latitude,
        widget.placeToEdit!.longitude,
      );

      // تحويل الـ SubPlaces لـ Maps عشان تتوافق مع الـ UI الحالي
      for (var sp in widget.placeToEdit!.subPlaces) {
        _subPlaces.add({
          'playersNumber': sp.playersNumber.toString(),
          'price': sp.pricePerHour.toString(),
          'image': sp.imageUrl, // هنا ممكن تكون URL أو File path
          'id': sp.id,
        });
      }
    }

    // ─── Step 3 Auto-fill ─────────────────
    // ملاحظة: الصور القديمة URLs، والجديدة Files. الـ UI لازم يتعامل مع النوعين.
    // للتبسيط، هنضيف الـ paths القديمة في لستة مؤقتة
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

  // ─── BlocListener ─────────────────────────────────────────────────────────

  bool _listenWhen(AddPlaceState prev, AddPlaceState curr) {
    final newError =
        curr.errorMessage != null && curr.errorMessage != prev.errorMessage;
    final newSuccess = curr.isSuccess && !prev.isSuccess;
    return newError || newSuccess;
  }

  void _handleCubitListener(BuildContext context, AddPlaceState state) {
    print("we are in $state");
    if (state.isSuccess) {
      showSuccessDialog(context);
      Navigator.pop(context);
    } else if (state.errorMessage != null) {
      SnackBarUtils.showErrorSnackBar(context, state.errorMessage!);
    }
  }

  // ─── Step navigation ──────────────────────────────────────────────────────

  Future<void> _onStepContinue() async {
    final isEditMode = widget.placeToEdit != null;
    final cubit = context.read<AddPlaceCubit>();

    // ─── STEP 1: Basic Info & Owner Validation ───
    if (_currentStep == 0) {
      final owner = cubit.state.selectedOwner;
      if (owner == null) {
        SnackBarUtils.showErrorSnackBar(
          context,
          context.tr('Please search and select an owner'),
        );
        return;
      }
      final isFormValid = _step1FormKey.currentState?.validate() ?? false;
      if (!isFormValid) return;
      if (_selectedCategory == null) {
        SnackBarUtils.showErrorSnackBar(
          context,
          context.tr('Please select a category'),
        );
        return;
      }
      setState(() => _currentStep++);
      return;
    }

    // ─── STEP 2: SubPlaces & Location Validation ───
    if (_currentStep == 1) {
      if (_subPlaces.isEmpty) {
        SnackBarUtils.showErrorSnackBar(
          context,
          context.tr('Please add at least one subplace'),
        );
        return;
      }
      // Validation Loop for SubPlaces
      for (int i = 0; i < _subPlaces.length; i++) {
        final sp = _subPlaces[i];
        final price = sp['price']?.toString().trim() ?? '';
        final players = sp['playersNumber']?.toString().trim() ?? '';

        if (price.isEmpty || players.isEmpty) {
          SnackBarUtils.showErrorSnackBar(
            context,
            '${context.tr('Please fill price and players for field')} #${i + 1}',
          );
          return;
        }
      }
      setState(() => _currentStep++);
      return;
    }

    // ─── STEP 3: Media & Final Save/Update ───
    if (_currentStep == 2) {
      // التأكد إن فيه صور (سواء قديمة موجودة أو جديدة مضافة)
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

      // تجهيز لستة الـ SubPlaces (تحويل الـ Map لـ Model)
      final subPlacesModels = _subPlaces.asMap().entries.map((entry) {
        final i = entry.key;
        final sp = entry.value;

        // هنا الذكاء: لو الصورة File هناخد الـ path، لو String (URL) هينزل زي ما هو
        String finalImgPath = '';
        if (sp['image'] is File) {
          finalImgPath = (sp['image'] as File).path;
        } else if (sp['image'] is String) {
          finalImgPath = sp['image'] as String;
        }

        return SubPlace(
          id: sp['id'] ?? 'sub_$i', // الحفاظ على الـ ID القديم في التعديل
          imageUrl: finalImgPath,
          pricePerHour: double.tryParse(sp['price'].toString()) ?? 0.0,
          playersNumber: int.tryParse(sp['playersNumber'].toString()) ?? 0,
        );
      }).toList();

      final opening = _isOpen24_7 ? '00:00 AM' : _openingTime;
      final closing = _isOpen24_7 ? '00:00 AM' : _closingTime;

      // تجميع الـ Object النهائي
      // لو إحنا في EditMode بنستخدم copyWith على الـ placeToEdit عشان نحافظ على الـ ID والحقول الثابتة
      final finalPlaceData =
          (isEditMode ? widget.placeToEdit! : cubit.state.place).copyWith(
            name: _nameController.text.trim(),
            description: _descController.text.trim(),
            type: _selectedCategory ?? '',
            ownerId: owner.id,
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
            // دمج الصور الجديدة مع القديمة (الـ Cubit هيتعامل مع الرفع)
            images: _mainImages.map((f) => f.path).toList(),
            subPlaces: subPlacesModels,
            minimumCharge: _minChargeController.text.trim().isNotEmpty
                ? double.tryParse(_minChargeController.text.trim())
                : null,
          );

      // تنفيذ العملية بناءً على الحالة
      if (isEditMode) {
        // ميثود في الكيوبيت مخصصة للتحديث
        await cubit.updateExistingPlace(finalPlaceData);
      } else {
        cubit.updatePlace(finalPlaceData);
        await cubit.savePlace();
      }
    }
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
            child: BlocListener<AddPlaceCubit, AddPlaceState>(
              listenWhen: _listenWhen,
              listener: _handleCubitListener,
              child: Column(
                children: [
                  CustAppBar(width: size.width),
                  const AddPlaceSearchBar(),
                  _buildStepperContainer(context),
                ],
              ),
            ),
          ),
          const LoadingOverlay(),
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
