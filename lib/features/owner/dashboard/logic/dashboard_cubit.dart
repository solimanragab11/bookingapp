import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/db/auth_service.dart';
import 'package:remaking_booking_app_trail2/features/owner/data/data_sources/firestore_owner_service.dart';
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
