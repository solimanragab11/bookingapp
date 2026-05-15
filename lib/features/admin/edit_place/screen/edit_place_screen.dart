import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/models/subplace.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/widgets/background.dart';

class EditPlaceScreen extends StatefulWidget {
  final PlaceModel place;
  const EditPlaceScreen({super.key, required this.place});

  @override
  State<EditPlaceScreen> createState() => _EditPlaceScreenState();
}

class _EditPlaceScreenState extends State<EditPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;

  // لستة الصور الرئيسية للمكان
  List<String> _existingPlaceImages = [];
  List<File> _newPlaceImages = [];

  // لستة الـ SubPlaces
  late List<SubPlace> _subPlaces;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.place.name);
    _descController = TextEditingController(text: widget.place.description);
    _existingPlaceImages = List.from(widget.place.images);
    _subPlaces = List.from(widget.place.subPlaces);
  }

  // فنكشن اختيار صور للمكان أو للـ Subplace
  Future<void> _pickImage({int? subPlaceIndex}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (subPlaceIndex == null) {
          _newPlaceImages.add(File(pickedFile.path));
        } else {
          // تحديث صورة الـ Subplace (بما إن الـ Model شايل ImageUrl واحدة)
          // هنا بنفترض إننا بنخزن المسار المحلي مؤقتاً
          _subPlaces[subPlaceIndex].imageUrl = pickedFile.path;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr("Edit Place"),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            onPressed: () {}, // ميثود حذف المكان بالكامل
          ),
        ],
      ),
      body: Stack(
        children: [
          BackGround(h: size.height, w: size.width),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Main Place Images"),
                    const SizedBox(height: 10),
                    _buildMainImageSection(),
                    const SizedBox(height: 20),
                    _buildTextField(
                      _nameController,
                      "Place Name",
                      Icons.business,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      _descController,
                      "Description",
                      Icons.info,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle("Sub-Places & Pricing"),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.black,
                          ),
                          onPressed: () => setState(
                            () => _subPlaces.add(
                              SubPlace(
                                id: "new",
                                pricePerHour: 0,
                                playersNumber: 0,
                                imageUrl: "",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _subPlaces.length,
                      itemBuilder: (context, index) =>
                          _buildSubPlaceCard(index),
                    ),
                    const SizedBox(height: 30),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ويدجت صور المكان الرئيسي
  Widget _buildMainImageSection() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          GestureDetector(
            onTap: () => _pickImage(),
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_a_photo, color: Colors.black),
            ),
          ),
          const SizedBox(width: 10),
          ..._existingPlaceImages.map(
            (url) => _buildImageThumbnail(url, isUrl: true),
          ),
          ..._newPlaceImages.map(
            (file) => _buildImageThumbnail(file, isUrl: false),
          ),
        ],
      ),
    );
  }

  Widget _buildImageThumbnail(dynamic source, {required bool isUrl}) {
    return Stack(
      children: [
        Container(
          width: 100,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: isUrl
                  ? NetworkImage(source)
                  : FileImage(source) as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 2,
          right: 10,
          child: GestureDetector(
            onTap: () => setState(
              () => isUrl
                  ? _existingPlaceImages.remove(source)
                  : _newPlaceImages.remove(source),
            ),
            child: const CircleAvatar(
              radius: 10,
              backgroundColor: Colors.red,
              child: Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // كارت الـ Sub-place مع تعديل الصورة الخاصة به
  Widget _buildSubPlaceCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(
          0.9,
        ), // خليته فاتح عشان النص الأسود يبان
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _pickImage(subPlaceIndex: index),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                    image: _subPlaces[index].imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: _subPlaces[index].imageUrl.startsWith('http')
                                ? NetworkImage(_subPlaces[index].imageUrl)
                                : FileImage(File(_subPlaces[index].imageUrl))
                                      as ImageProvider,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _subPlaces[index].imageUrl.isEmpty
                      ? const Icon(Icons.camera_alt, color: Colors.black)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => setState(() => _subPlaces.removeAt(index)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSubTextField(
                  initialValue: _subPlaces[index].pricePerHour.toString(),
                  label: "Price/hr",
                  isNumber: true,
                  onChanged: (v) =>
                      _subPlaces[index].pricePerHour = double.tryParse(v) ?? 0,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSubTextField(
                  initialValue: _subPlaces[index].playersNumber.toString(),
                  label: "Max Players",
                  isNumber: true,
                  onChanged: (v) =>
                      _subPlaces[index].playersNumber = int.tryParse(v) ?? 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widgets مساعدة للنصوص السوداء
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: context.tr(label),
        labelStyle: const TextStyle(color: Colors.black54),
        prefixIcon: Icon(icon, color: Colors.black),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSubTextField({
    required String initialValue,
    required String label,
    bool isNumber = false,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: context.tr(label),
        labelStyle: const TextStyle(color: Colors.black54, fontSize: 12),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black26),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      context.tr(title),
      style: const TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            /* نادى الكيوبيت هنا */
          }
        },
        child: Text(
          context.tr("Update Everything"),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
