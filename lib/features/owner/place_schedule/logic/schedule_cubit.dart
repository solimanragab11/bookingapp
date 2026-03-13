import 'package:bloc/bloc.dart';
import 'package:remaking_booking_app_trail2/features/owner/place_schedule/logic/schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit() : super(ScheduleState.initial());

  void selectDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
  }

  void selectSubPlace(int index) {
    emit(state.copyWith(selectedSubPlaceIndex: index));
  }

  void toggleSlot(String slot, bool isBooked) {
    final currentSlots = List<String>.from(state.selectedSlots);
    bool? selectingBooked = state.isSelectingBooked;

    if (currentSlots.isEmpty) {
      selectingBooked = isBooked;
      currentSlots.add(slot);
    } else {
      if (selectingBooked != isBooked) {
        // منع خلط المحجوز مع المتاح في اختيار واحد
        return;
      }
      if (currentSlots.contains(slot)) {
        currentSlots.remove(slot);
      } else {
        currentSlots.add(slot);
      }
      if (currentSlots.isEmpty) {
        selectingBooked = null;
      }
    }

    emit(
      state.copyWith(
        selectedSlots: currentSlots,
        isSelectingBooked: () => selectingBooked,
      ),
    );
  }

  void clearSelection() {
    emit(
      state.copyWith(
        selectedSlots: const [],
        isSelectingBooked: () => null,
      ),
    );
  }
}

