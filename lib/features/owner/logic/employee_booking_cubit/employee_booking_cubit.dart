import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hanzbthalk/features/owner/logic/employee_booking_cubit/employee_booking_state.dart';

class EmployeeBookingCubit extends Cubit<EmployeeBookingState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  EmployeeBookingCubit() : super(EmployeeBookingInitial());

  Future<void> markPendingNoShow({
    required String bookingId,
  }) async {
    emit(EmployeeBookingLoading());
    debugPrint("[EmployeeBookingCubit] Starting markPendingNoShow for bookingId: $bookingId");
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'pending_no_show',
      });
      debugPrint("[EmployeeBookingCubit] Success: Booking status set to 'pending_no_show'");
      emit(EmployeeBookingSuccess("no_show_marked_pending_success"));
    } catch (e) {
      debugPrint("[EmployeeBookingCubit] Error marking pending no-show: $e");
      emit(EmployeeBookingFailure(e.toString()));
    }
  }

  Future<void> confirmCashCollection({
    required String bookingId,
    required String enteredPin,
  }) async {
    emit(EmployeeBookingLoading());
    debugPrint("[EmployeeBookingCubit] Confirming cash collection for bookingId: $bookingId. Entered PIN: $enteredPin");
    try {
      final doc = await _firestore.collection('bookings').doc(bookingId).get();
      if (!doc.exists) {
        debugPrint("[EmployeeBookingCubit] Booking not found.");
        emit(EmployeeBookingFailure("booking_not_found"));
        return;
      }
      final data = doc.data()!;
      final actualPin = data['cashPin'] as String?;
      
      debugPrint("[EmployeeBookingCubit] Database actualPin: $actualPin");
      if (actualPin == null) {
        emit(EmployeeBookingFailure("cash_pin_not_set"));
        return;
      }

      if (enteredPin.trim() != actualPin.trim()) {
        debugPrint("[EmployeeBookingCubit] PIN Mismatch!");
        emit(EmployeeBookingFailure("invalid_cash_pin"));
        return;
      }

      final double totalPrice = (data['totalPrice'] ?? 0.0).toDouble();
      await _firestore.collection('bookings').doc(bookingId).update({
        'paidAmount': totalPrice,
        'isCashSettled': true,
      });
      debugPrint("[EmployeeBookingCubit] Success: isCashSettled updated to true.");
      emit(EmployeeBookingSuccess("cash_settled_success"));
    } catch (e) {
      debugPrint("[EmployeeBookingCubit] Error updating isCashSettled: $e");
      emit(EmployeeBookingFailure(e.toString()));
    }
  }

  Future<void> settleRemainingPayment({
    required String bookingId,
    required double totalPrice,
  }) async {
    emit(EmployeeBookingLoading());
    debugPrint("[EmployeeBookingCubit] Settling remaining payment for bookingId: $bookingId. Total Price: $totalPrice");
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'paidAmount': totalPrice,
        'isCashSettled': true,
      });
      debugPrint("[EmployeeBookingCubit] Success: Remaining payment settled (paidAmount set to $totalPrice, isCashSettled set to true).");
      emit(EmployeeBookingSuccess("remaining_payment_settled_success"));
    } catch (e) {
      debugPrint("[EmployeeBookingCubit] Error settling remaining payment: $e");
      emit(EmployeeBookingFailure(e.toString()));
    }
  }
}
