import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:remaking_booking_app_trail2/core/localization/localization_extension.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';

class MapSelectionScreen extends StatefulWidget {
  const MapSelectionScreen({super.key});

  @override
  State<MapSelectionScreen> createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  GoogleMapController? _mapController;
  LatLng? _pickedLocation;
  final TextEditingController _searchController = TextEditingController();

  // دالة البحث عن مكان بالاسم
  Future<void> _searchAddress() async {
    if (_searchController.text.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(
        _searchController.text,
      );
      if (locations.isNotEmpty) {
        LatLng target = LatLng(
          locations.first.latitude,
          locations.first.longitude,
        );
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, 16));
        setState(() => _pickedLocation = target);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('locationNotFound'))));
    }
  }

  // دالة تحديد موقعي الحالي
  Future<void> _locateMe() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    LatLng current = LatLng(position.latitude, position.longitude);

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(current, 17));
    setState(() => _pickedLocation = current);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. الخريطة
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(30.0444, 31.2357),
              zoom: 14,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onTap: (loc) => setState(() => _pickedLocation = loc),
            myLocationEnabled: true,
            myLocationButtonEnabled:
                false, // هنشيل الزرار الافتراضي ونعمل بتاعنا الشيك
            markers: _pickedLocation == null
                ? {}
                : {
                    Marker(
                      markerId: const MarkerId("selected"),
                      position: _pickedLocation!,
                    ),
                  },
          ),

          // 2. شريط البحث (Search Bar)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: ColorManager.cardSurface,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 10),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "ابحث عن عنوان الملعب...",
                        hintStyle: const TextStyle(color: Colors.white54),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: ColorManager.wasabi,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: ColorManager.wasabi,
                          ),
                          onPressed: _searchAddress,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                      ),
                      onSubmitted: (_) => _searchAddress(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. زرار التأكيد (يرجعنا للصفحة اللي فاتت)
          if (_pickedLocation != null)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.wasabi,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context, _pickedLocation),
                child: const Text(
                  "تأكيد هذا الموقع",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),

      // 4. زرار Locate Me
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorManager.noirDeVigne,
        child: const Icon(Icons.my_location, color: ColorManager.wasabi),
        onPressed: _locateMe,
      ),
    );
  }
}
