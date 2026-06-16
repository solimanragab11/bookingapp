import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 🔴 استدعاء الفايربيز
import 'package:hanzbthalk/core/models/offer_model.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/widgets/background.dart';
import 'package:hanzbthalk/features/admin/offer/offer_list/logic/offers_cubit.dart';

// 🔴 تأكد إن المسارات دي صحيحة عندك وشيل الكومنت من عليها
// import 'package:hanzbthalk/features/admin/offer/offer_mngm/model/offer.dart';
// import 'package:hanzbthalk/features/admin/offer/offer_mngm/cubit/offers_cubit.dart';

class OfferFormPage extends StatefulWidget {
  final OfferModel? offerData;

  const OfferFormPage({super.key, this.offerData});

  @override
  State<OfferFormPage> createState() => _OfferFormPageState();
}

class _OfferFormPageState extends State<OfferFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool get isEditMode => widget.offerData != null;

  bool isSaving = false;

  late TextEditingController titleController;
  late TextEditingController descController;
  late TextEditingController discountController;

  DateTime validFrom = DateTime.now();
  DateTime validUntil = DateTime.now().add(const Duration(days: 7));

  String? selectedPlaceId;
  String? selectedPlaceName;
  String? selectedSubPlaceId;
  String? selectedSubPlaceName;
  String offerTarget = 'whole';

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(
      text: isEditMode ? widget.offerData!.title : '',
    );
    descController = TextEditingController(
      text: isEditMode ? widget.offerData!.description : '',
    );
    discountController = TextEditingController(
      text: isEditMode ? widget.offerData!.discountPercentage.toString() : '',
    );

    if (isEditMode) {
      validFrom = widget.offerData!.validFrom;
      validUntil = widget.offerData!.validUntil;
      selectedPlaceId = widget.offerData!.placeId;
      selectedPlaceName =
          "Place: ${widget.offerData!.placeId.substring(0, 5)}...";
      offerTarget = widget.offerData!.isWholePlace ? 'whole' : 'sub';
      selectedSubPlaceId = widget.offerData!.subPlaceId;
      selectedSubPlaceName = selectedSubPlaceId != null
          ? "Sub Place $selectedSubPlaceId"
          : null;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    discountController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || selectedPlaceId == null) {
      if (selectedPlaceId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a target place!')),
        );
      }
      return;
    }

    if (offerTarget == 'sub' && selectedSubPlaceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a specific sub-place!')),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final cubit = context.read<OffersCubit>();

      final offerToSave = OfferModel(
        id: isEditMode ? widget.offerData!.id : cubit.getNewOfferId(),
        title: titleController.text.trim(),
        description: descController.text.trim(),
        discountPercentage: double.parse(discountController.text.trim()),
        validFrom: validFrom,
        validUntil: validUntil,
        placeId: selectedPlaceId!,
        isWholePlace: offerTarget == 'whole',
        subPlaceId: offerTarget == 'sub' ? selectedSubPlaceId : null,
        createdAt: isEditMode ? widget.offerData!.createdAt : DateTime.now(),
      );

      if (isEditMode) {
        await cubit.updateOffer(offerToSave);
      } else {
        await cubit.saveOffer(offerToSave);
      }

      if (mounted) {
        Navigator.pop(context);
        cubit.fetchOffers();
      }
    } catch (e) {
      setState(() => isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving offer: $e')));
      }
    }
  }

  void _showSearchBottomSheet({
    required String title,
    required List<Map<String, String>> items,
    required Function(String id, String name) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            String searchQuery = '';
            final filteredItems = items
                .where(
                  (element) => element['name']!.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ),
                )
                .toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.55,
                child: Column(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: const TextStyle(color: Colors.black45),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: ColorManager.wasabi,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: ColorManager.wasabi,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (val) =>
                          setStateSheet(() => searchQuery = val),
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              filteredItems[index]['name']!,
                              style: const TextStyle(color: Colors.black87),
                            ),
                            trailing: const Icon(
                              Icons.check_circle_outline,
                              color: ColorManager.wasabi,
                            ),
                            onTap: () {
                              onSelected(
                                filteredItems[index]['id']!,
                                filteredItems[index]['name']!,
                              );
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 🌟 دالة مساعدة لعرض اللودينج الشفاف
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: ColorManager.wasabi),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width > 600;

    final inputDecorationTheme = InputDecoration(
      labelStyle: const TextStyle(color: Colors.black54, fontSize: 15),
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 15),
      floatingLabelStyle: const TextStyle(color: ColorManager.wasabi),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black26),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black26),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ColorManager.wasabi, width: 1.5),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Offer' : 'Add New Offer',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: ColorManager.wasabi,
        elevation: 0,
        actions: [
          if (isEditMode)
            IconButton(
              icon: const Icon(
                Icons.delete_forever,
                color: Colors.redAccent,
                size: 28,
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Offer'),
                    content: const Text(
                      'Are you sure you want to delete this offer?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true && mounted) {
                  final cubit = context.read<OffersCubit>();
                  await cubit.deleteOffer(widget.offerData!.id);
                  Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          BackGround(h: size.height, w: size.width),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? size.width * 0.15 : 20,
                  vertical: 20,
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. جلب الأماكن الحقيقية من الفايربيز
                        GestureDetector(
                          onTap: () async {
                            _showLoadingDialog(); // عرض التحميل

                            try {
                              // جلب الداتا من كولكشن places
                              final snapshot = await FirebaseFirestore.instance
                                  .collection('places')
                                  .get();

                              if (!mounted) return;
                              Navigator.pop(context); // إخفاء التحميل

                              // تحويل الداتا لليست
                              final places = snapshot.docs.map((doc) {
                                return {
                                  'id': doc.id,
                                  // تأكد إن اسم الحقل في الفايربيز عندك هو name
                                  'name':
                                      doc.data()['name']?.toString() ??
                                      'Unnamed Place',
                                };
                              }).toList();

                              _showSearchBottomSheet(
                                title: 'Select a Place',
                                items: places,
                                onSelected: (id, name) {
                                  setState(() {
                                    selectedPlaceId = id;
                                    selectedPlaceName = name;
                                    selectedSubPlaceId = null;
                                    selectedSubPlaceName = null;
                                  });
                                },
                              );
                            } catch (e) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error loading places: $e'),
                                ),
                              );
                            }
                          },
                          child: InputDecorator(
                            decoration: inputDecorationTheme.copyWith(
                              labelText: 'Target Place',
                              prefixIcon: const Icon(
                                Icons.location_on,
                                color: ColorManager.wasabi,
                              ),
                            ),
                            child: Text(
                              selectedPlaceName ?? 'Tap to select a place...',
                              style: TextStyle(
                                fontSize: 16,
                                color: selectedPlaceName == null
                                    ? Colors.black38
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 2. نوع الخصم
                        const Text(
                          "Offer Scope:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 10,
                          runSpacing: 5,
                          alignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Radio<String>(
                                  value: 'whole',
                                  groupValue: offerTarget,
                                  activeColor: ColorManager.wasabi,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  onChanged: (val) =>
                                      setState(() => offerTarget = val!),
                                ),
                                const Text(
                                  "Whole Place",
                                  style: TextStyle(color: Colors.black87),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Radio<String>(
                                  value: 'sub',
                                  groupValue: offerTarget,
                                  activeColor: ColorManager.wasabi,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  onChanged: (val) =>
                                      setState(() => offerTarget = val!),
                                ),
                                const Text(
                                  "Specific Sub-Place",
                                  style: TextStyle(color: Colors.black87),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // 3. جلب الملاعب الفرعية الحقيقية من الفايربيز
                        if (offerTarget == 'sub') ...[
                          GestureDetector(
                            onTap: () async {
                              if (selectedPlaceId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please select a place first!',
                                    ),
                                  ),
                                );
                                return;
                              }

                              _showLoadingDialog(); // عرض التحميل

                              try {
                                // جلب الداتا من الـ sub-collection اللي اسمه subPlaces
                                final snapshot = await FirebaseFirestore
                                    .instance
                                    .collection('places')
                                    .doc(selectedPlaceId)
                                    .collection('subPlaces')
                                    .get();

                                if (!mounted) return;
                                Navigator.pop(context); // إخفاء التحميل

                                final subPlaces = snapshot.docs.map((doc) {
                                  return {
                                    'id': doc.id,
                                    // تأكد إن اسم الحقل في الفايربيز عندك هو name
                                    'name':
                                        doc.data()['name']?.toString() ??
                                        'Unnamed Court',
                                  };
                                }).toList();

                                if (subPlaces.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'No sub-places found for this place.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                _showSearchBottomSheet(
                                  title: 'Select Sub-Place',
                                  items: subPlaces,
                                  onSelected: (id, name) {
                                    setState(() {
                                      selectedSubPlaceId = id;
                                      selectedSubPlaceName = name;
                                    });
                                  },
                                );
                              } catch (e) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error loading sub-places: $e',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: InputDecorator(
                              decoration: inputDecorationTheme.copyWith(
                                labelText: 'Sub-Place',
                                prefixIcon: const Icon(
                                  Icons.sports_soccer,
                                  color: ColorManager.wasabi,
                                ),
                              ),
                              child: Text(
                                selectedSubPlaceName ??
                                    'Tap to select a sub-place...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: selectedSubPlaceName == null
                                      ? Colors.black38
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // 4. الحقول النصية
                        TextFormField(
                          controller: titleController,
                          style: const TextStyle(color: Colors.black87),
                          decoration: inputDecorationTheme.copyWith(
                            labelText: 'Offer Title',
                            hintText: 'Enter offer title',
                          ),
                          validator: (val) => val!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: descController,
                          maxLines: 2,
                          style: const TextStyle(color: Colors.black87),
                          decoration: inputDecorationTheme.copyWith(
                            labelText: 'Description',
                            hintText: 'Enter description',
                          ),
                          validator: (val) => val!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: discountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.black87),
                          decoration: inputDecorationTheme.copyWith(
                            labelText: 'Discount Percentage (%)',
                            hintText: '0',
                            prefixIcon: const Icon(
                              Icons.percent,
                              color: ColorManager.wasabi,
                            ),
                          ),
                          validator: (val) => val!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 20),

                        // 5. تواريخ البداية والنهاية
                        Row(
                          children: [
                            Expanded(
                              child: _buildDatePicker(
                                label: "Valid From",
                                date: validFrom,
                                theme: inputDecorationTheme,
                                onTap: () async {
                                  DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: validFrom,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setState(() => validFrom = picked);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildDatePicker(
                                label: "Valid Until",
                                date: validUntil,
                                theme: inputDecorationTheme,
                                onTap: () async {
                                  DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: validUntil.isBefore(validFrom)
                                        ? validFrom
                                        : validUntil,
                                    firstDate: validFrom,
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setState(() => validUntil = picked);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 35),

                        // 6. زر الحفظ مع حالة التحميل
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorManager.wasabi,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: isSaving ? null : _submitForm,
                            child: isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    isEditMode
                                        ? 'Update Offer'
                                        : 'Publish Offer',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime date,
    required InputDecoration theme,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: theme.copyWith(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 15,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "${date.year}/${date.month}/${date.day}",
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.calendar_month,
              color: ColorManager.wasabi,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
