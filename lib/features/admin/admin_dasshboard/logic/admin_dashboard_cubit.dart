import 'dart:async'; // ضروري عشان الـ StreamSubscription
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/features/admin/admin_dasshboard/repo/admin_dashboard_repo.dart';
import 'admin_dashboard_state.dart';

class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  final AdminDashBoardRepo _repository;

  // بنعرف Subscription عشان نقدر نقفله لما الـ Cubit يتمسح من الـ Memory
  StreamSubscription? _statsSubscription;

  AdminDashboardCubit(this._repository) : super(AdminDashboardInitial());

  // تغيير الميثود لتبدأ مراقبة الـ Stream
  void getLiveStats() {
    emit(AdminDashboardLoading());

    // بنلغي أي اشتراك قديم للأمان
    _statsSubscription?.cancel();

    // بنبدأ نسمع للـ Repo
    _statsSubscription = _repository.getDashboardStatsStream().listen(
      (stats) {
        // أول ما تيجي داتا (أو تتحدث)، بنبعت Success State
        emit(AdminDashboardSuccess(stats));
      },
      onError: (error) {
        // لو حصل مشكلة في الـ Stream
        emit(AdminDashboardError(error.toString()));
      },
    );
  }

  // ميثود الحذف مش محتاجة تعمل loadDashboardData يدوي خلاص!
  // لأن الـ Stream هيحس بالحذف ويحدث الـ UI لوحده
  Future<void> deletePlace(String id) async {
    try {
      await _repository.deletePlace(id);
      // مفيش داعي لمناداة أي حاجة هنا، الـ Stream قايم بالواجب
    } catch (e) {
      emit(AdminDashboardError("Delete failed: $e"));
    }
  }

  // مهم جداً: نقفل الـ Subscription لما الـ Cubit يموت عشان ميعملش Memory Leak
  @override
  Future<void> close() {
    _statsSubscription?.cancel();
    return super.close();
  }
}
