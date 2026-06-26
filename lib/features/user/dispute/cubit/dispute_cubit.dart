import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hanzbthalk/features/user/dispute/cubit/dispute_state.dart';
import 'package:hanzbthalk/core/models/booking_model.dart';
import 'package:hanzbthalk/core/models/slots_model.dart';
import 'package:hanzbthalk/core/models/booking_id_model.dart';
import 'package:hanzbthalk/core/db/app_notification_helper.dart';

class DisputeCubit extends Cubit<DisputeState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DisputeCubit() : super(DisputeInitial());

  Future<void> disputeNoShow({
    required String bookingId,
    required String placeId,
  }) async {
    emit(DisputeLoading());
    debugPrint("\n================== [ START GPS DISPUTE ] ==================");
    debugPrint("bookingId: $bookingId, placeId: $placeId");

    try {
      // 1. Fetch user data to have it ready in case of failure or success
      final bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
      if (!bookingDoc.exists || bookingDoc.data() == null) {
        emit(DisputeFailure("booking_not_found"));
        return;
      }
      final String userId = bookingDoc.data()?['userId'] ?? '';
      
      final userDoc = await _firestore.collection('users').doc(userId).get();
      int noShowCount = 0;
      int currentPoints = 0;
      if (userDoc.exists && userDoc.data() != null) {
        noShowCount = userDoc.data()?['noShowCount'] ?? 0;
        currentPoints = userDoc.data()?['points'] ?? 0;
      }
      
      debugPrint("User stats loaded: noShowCount=$noShowCount, points=$currentPoints");

      debugPrint("📍 Checking if Location services are enabled...");
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint("❌ Location services disabled");
        emit(DisputeFailure("gps_disabled_error"));
        return;
      }

      debugPrint("📍 Checking Location permission...");
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint("❌ Permission denied");
          emit(DisputeFailure("gps_permission_denied"));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint("❌ Permission denied forever");
        emit(DisputeFailure("gps_permission_denied_forever"));
        return;
      }

      debugPrint("📍 Getting user current position...");
      Position userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      debugPrint("👤 User current location: Lat: ${userPosition.latitude}, Lng: ${userPosition.longitude}");

      debugPrint("🔍 Fetching place coordinates from Firestore...");
      final placeDoc = await _firestore.collection('places').doc(placeId).get();
      if (!placeDoc.exists || placeDoc.data() == null) {
        debugPrint("❌ Place not found in Firestore");
        emit(DisputeFailure("place_not_found_error"));
        return;
      }

      final placeData = placeDoc.data()!;
      final double? placeLat = (placeData['latitude'] as num?)?.toDouble();
      final double? placeLng = (placeData['longitude'] as num?)?.toDouble();

      if (placeLat == null || placeLng == null) {
        debugPrint("❌ Place has no GPS coordinates registered");
        emit(DisputeFailure("place_gps_missing_error"));
        return;
      }
      debugPrint("Stadium Location: Lat: $placeLat, Lng: $placeLng");

      double distanceInMeters = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        placeLat,
        placeLng,
      );
      debugPrint("📏 Calculated distance: ${distanceInMeters.toStringAsFixed(2)} meters");

      if (distanceInMeters > 1000) {
        debugPrint("❌ GPS Dispute Failed: User is too far (> 1000 meters)");
        emit(DisputeTooFar(
          noShowCount: noShowCount,
          currentPoints: currentPoints,
          bookingId: bookingId,
          userId: userId,
        ));
        return;
      }

      debugPrint("💾 Overriding status back to 'attended' in Firestore...");
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'attended',
        'checkInTime': Timestamp.fromDate(DateTime.now()),
      });

      // Notify owner of GPS check-in/attendance
      AppNotificationHelper.notifyOwner(
        placeId: placeId,
        title: 'نزاع ناجح / Dispute Approved',
        body: 'تم إثبات حضور العميل للحجز رقم $bookingId عبر الـ GPS / The client\'s attendance was verified via GPS for booking $bookingId',
        data: {
          'bookingId': bookingId,
          'placeId': placeId,
        },
      );

      debugPrint("🎉 Dispute successful. Overrode status to 'attended'.");
      emit(DisputeSuccess("dispute_success_msg"));
    } catch (e, stackTrace) {
      debugPrint("🚨 Exception in disputeNoShow: $e");
      debugPrint("$stackTrace");
      emit(DisputeFailure(e.toString()));
    }
  }

  Future<void> admitNoShow({
    required String bookingId,
    required String userId,
  }) async {
    emit(DisputeLoading());
    debugPrint("\n================== [ ADMIT NO SHOW ] ==================");
    debugPrint("bookingId: $bookingId, userId: $userId");

    try {
      final userRef = _firestore.collection('users').doc(userId);
      final bookingRef = _firestore.collection('bookings').doc(bookingId);
      
      final bookingSnapshot = await bookingRef.get();
      if (!bookingSnapshot.exists || bookingSnapshot.data() == null) {
        emit(DisputeFailure("booking_not_found"));
        return;
      }
      
      final booking = BookingModel.fromJson(bookingSnapshot.data()!);
      final slotsRef = _firestore.collection('slots').doc(booking.subPlaceId);

      await _firestore.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userRef);
        final slotsSnapshot = await transaction.get(slotsRef);
        
        int currentPoints = 0;
        int currentNoShow = 0;
        int currentPenalty = 0;
        
        if (userSnapshot.exists && userSnapshot.data() != null) {
          final userData = userSnapshot.data()!;
          currentPoints = userData['points'] ?? 0;
          currentNoShow = userData['noShowCount'] ?? 0;
          currentPenalty = userData['penaltyBookingsLeft'] ?? 0;
        }
        
        final int newPoints = (currentPoints - 20).clamp(0, 9999999);
        final int newNoShow = currentNoShow + 1;
        int newPenalty = currentPenalty;
        if (newNoShow >= 2 && currentPenalty == 0) {
          newPenalty = 3;
        }
        
        // Update user stats
        transaction.update(userRef, {
          'points': newPoints,
          'noShowCount': newNoShow,
          'penaltyBookingsLeft': newPenalty,
        });

        // Release slots in transaction
        if (slotsSnapshot.exists && slotsSnapshot.data() != null) {
          final slots = SlotsModel.fromJson(slotsSnapshot.data()!);
          
          final Map<String, List<String>> freeTimeSlots = Map.from(
            slots.freeTimeSlots.map((key, value) => MapEntry(key, List<String>.from(value))),
          );
          final List<BookingIdModel> bookedTimeSlots = List.from(slots.bookedTimeSlots);

          for (var entry in booking.timeSlots.entries) {
            String day = entry.key;
            for (String slot in entry.value) {
              if (freeTimeSlots[day] == null) {
                freeTimeSlots[day] = [];
              }
              if (!freeTimeSlots[day]!.contains(slot)) {
                freeTimeSlots[day]!.add(slot);
                freeTimeSlots[day]!.sort();
              }
            }
          }
          
          bookedTimeSlots.removeWhere((b) => b.bookingId == booking.id);
          
          final updatedSlots = slots.copyWith(
            freeTimeSlots: freeTimeSlots,
            bookedTimeSlots: bookedTimeSlots,
          );
          transaction.update(slotsRef, updatedSlots.toJson());
        }
        
        // Update status to 'no_show'
        transaction.update(bookingRef, {
          'status': 'no_show',
        });
      });

      debugPrint("🎉 User admitted no-show. Penalty applied, slots released, status updated to 'no_show'.");
      emit(DisputeSuccess("admit_no_show_success"));
    } catch (e, stackTrace) {
      debugPrint("🚨 Error in admitNoShow: $e");
      debugPrint("$stackTrace");
      emit(DisputeFailure(e.toString()));
    }
  }
}
