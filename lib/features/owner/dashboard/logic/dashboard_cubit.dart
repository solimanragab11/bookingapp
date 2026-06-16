import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/db/auth_service.dart';
import 'package:hanzbthalk/core/db/firestore_owner_service.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final FirestoreOwnerService _firestore = FirestoreOwnerService(AuthService());

  DashboardCubit() : super(DashboardInitial());
  // جوه الـ DashboardCubit
  StreamSubscription? _statsSubscription;

  void getRealTimeStats(String placeId, DateTime start, DateTime end) {
    emit(DashboardLoading());

    // نلغي أي اشتراك قديم لو موجود
    _statsSubscription?.cancel();

    _statsSubscription = _firestore
        .getDashboardStatsStream(
          placeId: placeId,
          startDate: start,
          endDate: end,
        )
        .listen(
          (stats) {
            emit(DashboardLoaded(stats));
          },
          onError: (error) {
            emit(DashboardError(error.toString()));
          },
        );
  }

  @override
  Future<void> close() {
    _statsSubscription?.cancel(); // مهم جداً عشان الميموري
    return super.close();
  }
}
