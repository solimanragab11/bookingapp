// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/widgets/snackbar_utils.dart';

class MapSelectionScreen extends StatefulWidget {
  const MapSelectionScreen({super.key});

  @override
  State<MapSelectionScreen> createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  GoogleMapController? _mapController;
  LatLng? _pickedLocation;
  String _pickedAddress = "";
  final TextEditingController _searchController = TextEditingController();
  bool _isLoadingAddress = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- 1. دالة تحويل الإحداثيات لعنوان نصي (Reverse Geocoding) ---
  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() => _isLoadingAddress = true);
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        // بنجمع تفاصيل العنوان (الشارع، المنطقة، المدينة)
        String address =
            "${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}";

        setState(() {
          _pickedAddress = address;
          _searchController.text =
              address; // بنعرض العنوان في السيرش بار عشان اليوزر يتأكد
        });
      }
    } catch (e) {
      debugPrint("Error fetching address: $e");
    } finally {
      setState(() => _isLoadingAddress = false);
    }
  }

  // --- 2. دالة البحث عن مكان بالاسم ---
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
        _moveToLocation(target);
      }
    } catch (e) {
      SnackBarUtils.showError(context, 'locationNotFound');
    }
  }

  // --- 3. دالة تحديد موقعي الحالي ---
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
    _moveToLocation(current);
  }

  // دالة مساعدة لتحريك الكاميرا وتحديث العنوان
  void _moveToLocation(LatLng target) {
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, 16));
    setState(() => _pickedLocation = target);
    _getAddressFromLatLng(target);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الخريطة
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(30.0444, 31.2357), // القاهرة كبداية
              zoom: 14,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onTap: (loc) => _moveToLocation(loc), // عند الضغط في أي مكان
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _pickedLocation == null
                ? {}
                : {
                    Marker(
                      markerId: const MarkerId("selected"),
                      position: _pickedLocation!,
                      infoWindow: InfoWindow(title: _pickedAddress),
                    ),
                  },
          ),

          // شريط البحث
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                decoration: BoxDecoration(
                  color: ColorManager.cardSurface,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 10),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "ابحث عن عنوان الملعب...",
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: _isLoadingAddress
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: ColorManager.wasabi,
                            ),
                          )
                        : const Icon(
                            Icons.location_on,
                            color: ColorManager.wasabi,
                          ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.search,
                        color: ColorManager.wasabi,
                      ),
                      onPressed: _searchAddress,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onSubmitted: (_) => _searchAddress(),
                ),
              ),
            ),
          ),

          // زرار التأكيد
          if (_pickedLocation != null)
            Positioned(
              bottom: 40,
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
                onPressed: () {
                  // بنرجع الـ Map فيها الإحداثيات والعنوان النصي
                  Navigator.pop(context, {
                    'location': _pickedLocation,
                    'address': _pickedAddress,
                  });
                },
                child: const Text(
                  "تأكيد هذا الموقع",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
        ],
      ),

      // زرار Locate Me
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: _pickedLocation != null ? 70 : 0),
        child: FloatingActionButton(
          backgroundColor: ColorManager.noirDeVigne,
          onPressed: _locateMe,
          child: const Icon(Icons.my_location, color: ColorManager.wasabi),
        ),
      ),
    );
  }
}
