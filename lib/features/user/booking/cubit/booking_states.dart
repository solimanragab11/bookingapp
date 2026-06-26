import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/core/models/subplace_model.dart';
import 'package:hanzbthalk/core/models/slots_model.dart';

abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

// class BookingDataState extends BookingState {
//   final String? selectedDay;
//   final Set<String> selectedBookingSlots;
//   final double originalTotalAmount; // السعر الأساسي (الميزان)
//   final double finalAmount; // السعر النهائي بعد الخصم
//   final double requiredDeposit;
//   final double minRequiredDeposit;
//   final double paidAmount;
//   final double remainingAmount;
//   final double pricePerhour;
//   final int usedPoints;
//   final bool isOffer; // خليتها final عشان الـ Immutability في الـ Bloc

//   BookingDataState({
//     this.pricePerhour = 0,
//     this.usedPoints = 0,
//     this.selectedDay,
//     this.selectedBookingSlots = const {},
//     this.originalTotalAmount = 0.0,
//     this.finalAmount = 0.0, // أضفنا ده
//     this.requiredDeposit = 0.0,
//     this.minRequiredDeposit = 0.0,
//     this.paidAmount = 0.0,
//     this.remainingAmount = 0.0,
//     this.isOffer = false,
//   });

//   // الـ copyWith لازم يشمل كل المتغيرات عشان الداتا ما تضيعش
//   BookingDataState copyWith({
//     String? selectedDay,
//     Set<String>? selectedBookingSlots,
//     double? originalTotalAmount,
//     double? finalAmount,
//     double? requiredDeposit,
//     double? minRequiredDeposit,
//     double? paidAmount,
//     double? remainingAmount,
//     int? usedPoints,
//     bool? isOffer,
//     double? pricePerhour,
//   }) {
//     return BookingDataState(
//       selectedDay: selectedDay ?? this.selectedDay,
//       selectedBookingSlots: selectedBookingSlots ?? this.selectedBookingSlots,
//       originalTotalAmount: originalTotalAmount ?? this.originalTotalAmount,
//       finalAmount: finalAmount ?? this.finalAmount,
//       requiredDeposit: requiredDeposit ?? this.requiredDeposit,
//       minRequiredDeposit: minRequiredDeposit ?? this.minRequiredDeposit,
//       paidAmount: paidAmount ?? this.paidAmount,
//       remainingAmount: remainingAmount ?? this.remainingAmount,
//       usedPoints: usedPoints ?? this.usedPoints,
//       isOffer: isOffer ?? this.isOffer,
//       pricePerhour: pricePerhour ?? this.pricePerhour,
//     );
//   }
// }

class BookingSuccess extends BookingState {
  final String message;
  BookingSuccess({required this.message});
}

class BookingFailure extends BookingState {
  final String errorMessage;
  BookingFailure({required this.errorMessage});
}

class BookingSlotsUnavailable extends BookingState {
  final String message;
  BookingSlotsUnavailable({required this.message});
}

class BookingDataState extends BookingState {
  final PlaceModel? place; // أضفنا ده
  final SubPlaceModel? liveSubPlace; // أضفنا ده
  final SlotsModel? slots; // أضفنا ده للـ Slots
  final String? selectedDay;
  final Set<String> selectedBookingSlots;
  final double originalTotalAmount;
  final double finalAmount;
  final double requiredDeposit;
  final double minRequiredDeposit;
  final double paidAmount;
  final double remainingAmount;
  final double pricePerhour;
  final int usedPoints;
  final int userPoints;
  final bool isOffer;
  final int noShowCount;
  final int penaltyBookingsLeft;

  BookingDataState({
    this.place,
    this.liveSubPlace,
    this.slots,
    this.pricePerhour = 0,
    this.usedPoints = 0,
    this.userPoints = 0,
    this.selectedDay,
    this.selectedBookingSlots = const {},
    this.originalTotalAmount = 0.0,
    this.finalAmount = 0.0,
    this.requiredDeposit = 0.0,
    this.minRequiredDeposit = 0.0,
    this.paidAmount = 0.0,
    this.remainingAmount = 0.0,
    this.isOffer = false,
    this.noShowCount = 0,
    this.penaltyBookingsLeft = 0,
  });

  BookingDataState copyWith({
    PlaceModel? place,
    SubPlaceModel? liveSubPlace,
    SlotsModel? slots,
    String? selectedDay,
    Set<String>? selectedBookingSlots,
    double? originalTotalAmount,
    double? finalAmount,
    double? requiredDeposit,
    double? minRequiredDeposit,
    double? paidAmount,
    double? remainingAmount,
    int? usedPoints,
    int? userPoints,
    bool? isOffer,
    double? pricePerhour,
    int? noShowCount,
    int? penaltyBookingsLeft,
  }) {
    return BookingDataState(
      place: place ?? this.place,
      liveSubPlace: liveSubPlace ?? this.liveSubPlace,
      slots: slots ?? this.slots,
      selectedDay: selectedDay ?? this.selectedDay,
      selectedBookingSlots: selectedBookingSlots ?? this.selectedBookingSlots,
      originalTotalAmount: originalTotalAmount ?? this.originalTotalAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      requiredDeposit: requiredDeposit ?? this.requiredDeposit,
      minRequiredDeposit: minRequiredDeposit ?? this.minRequiredDeposit,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      usedPoints: usedPoints ?? this.usedPoints,
      userPoints: userPoints ?? this.userPoints,
      isOffer: isOffer ?? this.isOffer,
      pricePerhour: pricePerhour ?? this.pricePerhour,
      noShowCount: noShowCount ?? this.noShowCount,
      penaltyBookingsLeft: penaltyBookingsLeft ?? this.penaltyBookingsLeft,
    );
  }
}

class SlotLockSuccess extends BookingDataState {
  final String messageKey;
  SlotLockSuccess({
    required this.messageKey,
    required BookingDataState dataState,
  }) : super(
         place: dataState.place,
         liveSubPlace: dataState.liveSubPlace,
         slots: dataState.slots,
         pricePerhour: dataState.pricePerhour,
         usedPoints: dataState.usedPoints,
         userPoints: dataState.userPoints,
         selectedDay: dataState.selectedDay,
         selectedBookingSlots: dataState.selectedBookingSlots,
         originalTotalAmount: dataState.originalTotalAmount,
         finalAmount: dataState.finalAmount,
         requiredDeposit: dataState.requiredDeposit,
         minRequiredDeposit: dataState.minRequiredDeposit,
         paidAmount: dataState.paidAmount,
         remainingAmount: dataState.remainingAmount,
         isOffer: dataState.isOffer,
         noShowCount: dataState.noShowCount,
         penaltyBookingsLeft: dataState.penaltyBookingsLeft,
       );
}

class SlotLockFailure extends BookingDataState {
  final String errorMessageKey;
  SlotLockFailure({
    required this.errorMessageKey,
    required BookingDataState dataState,
  }) : super(
         place: dataState.place,
         liveSubPlace: dataState.liveSubPlace,
         slots: dataState.slots,
         pricePerhour: dataState.pricePerhour,
         usedPoints: dataState.usedPoints,
         userPoints: dataState.userPoints,
         selectedDay: dataState.selectedDay,
         selectedBookingSlots: dataState.selectedBookingSlots,
         originalTotalAmount: dataState.originalTotalAmount,
         finalAmount: dataState.finalAmount,
         requiredDeposit: dataState.requiredDeposit,
         minRequiredDeposit: dataState.minRequiredDeposit,
         paidAmount: dataState.paidAmount,
         remainingAmount: dataState.remainingAmount,
         isOffer: dataState.isOffer,
         noShowCount: dataState.noShowCount,
         penaltyBookingsLeft: dataState.penaltyBookingsLeft,
       );
}

class PaymentLockSuccess extends BookingDataState {
  final String messageKey;
  PaymentLockSuccess({
    required this.messageKey,
    required BookingDataState dataState,
  }) : super(
         place: dataState.place,
         liveSubPlace: dataState.liveSubPlace,
         slots: dataState.slots,
         pricePerhour: dataState.pricePerhour,
         usedPoints: dataState.usedPoints,
         userPoints: dataState.userPoints,
         selectedDay: dataState.selectedDay,
         selectedBookingSlots: dataState.selectedBookingSlots,
         originalTotalAmount: dataState.originalTotalAmount,
         finalAmount: dataState.finalAmount,
         requiredDeposit: dataState.requiredDeposit,
         minRequiredDeposit: dataState.minRequiredDeposit,
         paidAmount: dataState.paidAmount,
         remainingAmount: dataState.remainingAmount,
         isOffer: dataState.isOffer,
         noShowCount: dataState.noShowCount,
         penaltyBookingsLeft: dataState.penaltyBookingsLeft,
       );
}

class PaymentLockFailure extends BookingDataState {
  final String errorMessageKey;
  PaymentLockFailure({
    required this.errorMessageKey,
    required BookingDataState dataState,
  }) : super(
         place: dataState.place,
         liveSubPlace: dataState.liveSubPlace,
         slots: dataState.slots,
         pricePerhour: dataState.pricePerhour,
         usedPoints: dataState.usedPoints,
         userPoints: dataState.userPoints,
         selectedDay: dataState.selectedDay,
         selectedBookingSlots: dataState.selectedBookingSlots,
         originalTotalAmount: dataState.originalTotalAmount,
         finalAmount: dataState.finalAmount,
         requiredDeposit: dataState.requiredDeposit,
         minRequiredDeposit: dataState.minRequiredDeposit,
         paidAmount: dataState.paidAmount,
         remainingAmount: dataState.remainingAmount,
         isOffer: dataState.isOffer,
         noShowCount: dataState.noShowCount,
         penaltyBookingsLeft: dataState.penaltyBookingsLeft,
       );
}
