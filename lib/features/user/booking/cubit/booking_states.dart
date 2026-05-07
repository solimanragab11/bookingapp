import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/models/subplace.dart';

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
  final SubPlace? liveSubPlace; // أضفنا ده
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
  final bool isOffer;

  BookingDataState({
    this.place,
    this.liveSubPlace,
    this.pricePerhour = 0,
    this.usedPoints = 0,
    this.selectedDay,
    this.selectedBookingSlots = const {},
    this.originalTotalAmount = 0.0,
    this.finalAmount = 0.0,
    this.requiredDeposit = 0.0,
    this.minRequiredDeposit = 0.0,
    this.paidAmount = 0.0,
    this.remainingAmount = 0.0,
    this.isOffer = false,
  });

  BookingDataState copyWith({
    PlaceModel? place,
    SubPlace? liveSubPlace,
    String? selectedDay,
    Set<String>? selectedBookingSlots,
    double? originalTotalAmount,
    double? finalAmount,
    double? requiredDeposit,
    double? minRequiredDeposit,
    double? paidAmount,
    double? remainingAmount,
    int? usedPoints,
    bool? isOffer,
    double? pricePerhour,
  }) {
    return BookingDataState(
      selectedDay: selectedDay ?? this.selectedDay,
      selectedBookingSlots: selectedBookingSlots ?? this.selectedBookingSlots,
      originalTotalAmount: originalTotalAmount ?? this.originalTotalAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      requiredDeposit: requiredDeposit ?? this.requiredDeposit,
      minRequiredDeposit: minRequiredDeposit ?? this.minRequiredDeposit,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      usedPoints: usedPoints ?? this.usedPoints,
      isOffer: isOffer ?? this.isOffer,
      pricePerhour: pricePerhour ?? this.pricePerhour,
    );
  }
}
