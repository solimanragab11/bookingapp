import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/features/owner/gloabal_dashboard/repo/global_dashboard_repository.dart';
import 'global_dashboard_state.dart';

class GlobalDashboardCubit extends Cubit<GlobalDashboardState> {
  final GlobalDashboardRepository _repository;

  GlobalDashboardCubit(this._repository) : super(GlobalDashboardInitial());

  Future<void> getGlobalDashboardData({required DateTime month}) async {
    emit(GlobalDashboardLoading());

    try {
      // بننادي الـ Repo اللي بيرجع BookingMonthlyReport واحد شامل
      final report = await _repository.fetchGlobalDashboardData(month: month);

      // بنبعت التقرير كامل للـ UI
      emit(GlobalDashboardLoaded(report));
    } catch (e) {
      emit(GlobalDashboardError(e.toString()));
    }
  }
}
