// lib/features/user/booking/presentation/cubit/check_in_cubit.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart'; // 🎯 ضفنا باكدج المواقع
import 'package:hanzbthalk/features/user/check_booking/cubit/check_in_state.dart';
import 'package:hanzbthalk/core/db/app_notification_helper.dart';

class CheckInCubit extends Cubit<CheckInState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CheckInCubit() : super(CheckInInitial());

  Future<void> validateAndCheckIn({
    required String userId,
    required String scannedVenueId,
  }) async {
    emit(CheckInLoading());

    debugPrint(
      "\n================== [ START QR + GPS CHECK-IN ] ==================",
    );

    try {
      // ==========================================
      // 🛡️ أولاً: التحقق من الـ GPS ومكان اللاعب
      // ==========================================
      debugPrint("📍 Checking GPS permissions...");
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(
          CheckInFailure("من فضلك قم بتشغيل الـ GPS (الموقع) في هاتفك أولاً."),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(CheckInFailure("لا يمكن تسجيل الحضور بدون صلاحية الموقع!"));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(
          CheckInFailure(
            "صلاحية الموقع مقفولة نهائياً، يرجى تفعيلها من إعدادات الهاتف.",
          ),
        );
        return;
      }

      debugPrint("📍 Getting user's current location...");
      Position userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      debugPrint(
        "👤 User Location: Lat: ${userPosition.latitude}, Lng: ${userPosition.longitude}",
      );

      debugPrint("🔍 Fetching Venue (Place) coordinates from Firestore...");
      // هنا بنجيب بيانات الملعب من كولكشن الـ places عشان نعرف اللوكيشن بتاعه
      final placeDoc = await _firestore
          .collection('places')
          .doc(scannedVenueId)
          .get();

      if (!placeDoc.exists || placeDoc.data() == null) {
        emit(CheckInFailure("بيانات هذا الملعب غير موجودة في النظام."));
        return;
      }

      final placeData = placeDoc.data()!;
      // افترض إنك مخزن خطوط الطول والعرض جوه الملعب بالأسماء دي، لو أسماء تانية عدلها
      final double? placeLat = placeData['latitude']?.toDouble();
      final double? placeLng = placeData['longitude']?.toDouble();

      if (placeLat == null || placeLng == null) {
        emit(
          CheckInFailure("لا يوجد إحداثيات GPS مسجلة لهذا الملعب في النظام."),
        );
        return;
      }

      debugPrint("🏟️ Place Location: Lat: $placeLat, Lng: $placeLng");

      // 📏 حساب المسافة بالمتر
      double distanceInMeters = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        placeLat,
        placeLng,
      );

      debugPrint(
        "📏 Distance between User and Place: ${distanceInMeters.toStringAsFixed(2)} meters",
      );

      // 🛑 الفلتر الأمني: لازم يكون في نطاق 1000 متر (1 كيلو)
      if (distanceInMeters > 1000) {
        debugPrint("❌ FAILURE: User is too far from the venue!");
        emit(
          CheckInFailure(
            "أنت بعيد عن الملعب! المسافة بينك وبين الملعب ${(distanceInMeters / 1000).toStringAsFixed(1)} كيلو. لازم تكون موجود في الملعب لتسجيل الحضور.",
          ),
        );
        return;
      }
      debugPrint("✅ GPS VALIDATION PASSED! User is within range.");

      // ==========================================
      // 🛡️ ثانياً: التحقق من الوقت وتأكيد الحجز
      // ==========================================
      final now = DateTime.now();
      debugPrint("🔍 Querying Firestore for active bookings...");
      final bookingsQuery = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .where('placeId', isEqualTo: scannedVenueId)
          .where('status', isEqualTo: 'active')
          .get();

      if (bookingsQuery.docs.isEmpty) {
        emit(CheckInFailure("ليس لديك حجز نشط في هذا الملعب اليوم كابتن!"));
        return;
      }

      DocumentSnapshot? validBookingDoc;

      for (var doc in bookingsQuery.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final timeSlots = data['timeSlots'] as Map<String, dynamic>?;

        if (timeSlots == null || timeSlots.isEmpty) continue;

        final String fullDay = timeSlots.keys.first;
        final List<dynamic> slots = timeSlots.values.first;
        final datePart = fullDay.split(' ').last;
        final dateComps = datePart.split('/');

        if (dateComps.length < 2) continue;

        int year = now.year;
        if (data['createdAt'] != null) {
          final createdAt = data['createdAt'];
          if (createdAt is Timestamp) year = createdAt.toDate().year;
        }

        final int day = int.parse(dateComps[0]);
        final int month = int.parse(dateComps[1]);

        DateTime? startTime;
        DateTime? endTime;

        for (var slot in slots) {
          final timeParts = slot.toString().split('-');
          final startHour = int.parse(timeParts[0].trim().split(':')[0]);
          final startMin = int.parse(timeParts[0].trim().split(':')[1]);
          final endHour = int.parse(timeParts[1].trim().split(':')[0]);
          final endMin = int.parse(timeParts[1].trim().split(':')[1]);

          final slotStart = DateTime(year, month, day, startHour, startMin);
          final slotEnd = DateTime(year, month, day, endHour, endMin);

          if (startTime == null || slotStart.isBefore(startTime))
            startTime = slotStart;
          if (endTime == null || slotEnd.isAfter(endTime)) endTime = slotEnd;
        }

        if (startTime == null || endTime == null) continue;

        final allowedStartTime = startTime.subtract(
          const Duration(minutes: 15),
        );
        if (now.isAfter(allowedStartTime) && now.isBefore(endTime)) {
          validBookingDoc = doc;
          break;
        }
      }

      if (validBookingDoc == null) {
        emit(
          CheckInFailure(
            "ميعاد حجزك مش دلوقتي! تقدر تعمل سكان قبل الماتش بـ 15 دقيقة.",
          ),
        );
        return;
      }

      debugPrint(
        "💾 Updating Firestore Document ID: ${validBookingDoc.id} to 'attended'...",
      );
      await _firestore.collection('bookings').doc(validBookingDoc.id).update({
        'status': 'attended',
        'checkInTime': Timestamp.fromDate(now),
      });

      // Notify owner of attendance
      final String placeId = validBookingDoc.get('placeId') ?? '';
      final String bookingId = validBookingDoc.id;
      if (placeId.isNotEmpty) {
        AppNotificationHelper.notifyOwner(
          placeId: placeId,
          title: 'إثبات حضور / Attendance Checked-In',
          body: 'تم إثبات حضور العميل للحجز رقم $bookingId / The client\'s attendance was checked-in for booking $bookingId',
          data: {
            'bookingId': bookingId,
            'placeId': placeId,
          },
        );
      }

      debugPrint(
        "🎉 SUCCESS: Booking updated successfully. Check-in complete.",
      );
      emit(CheckInSuccess("تم إثبات حضورك بنجاح! ماتش ممتع يا كابتن ⚽"));
    } catch (e, stackTrace) {
      debugPrint("🚨 EXCEPTION CAUGHT: $e");
      emit(CheckInFailure("حدث خطأ أثناء تسجيل الحضور: ${e.toString()}"));
    }
  }
}
