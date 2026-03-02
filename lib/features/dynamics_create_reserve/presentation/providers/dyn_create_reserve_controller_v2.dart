import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/dynamics_create_reserve/domain/usecases/get_dyn_reserve_data.dart';
import 'package:PiliPlus/features/dynamics_create_reserve/presentation/providers/dyn_create_reserve_providers.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_reserve_info/data.dart';
import 'package:PiliPlus/utils/utils.dart';

part 'dyn_create_reserve_controller_v2.g.dart';

/// Dynamics create reserve state
class DynCreateReserveState {
  final LoadingState<ReserveInfoData?> reserveInfoState;
  final int subType;
  final String title;
  final DateTime date;
  final bool canCreate;

  const DynCreateReserveState({
    required this.reserveInfoState,
    this.subType = 0,
    this.title = '',
    required this.date,
    this.canCreate = false,
  });

  DynCreateReserveState copyWith({
    LoadingState<ReserveInfoData?>? reserveInfoState,
    int? subType,
    String? title,
    DateTime? date,
    bool? canCreate,
  }) {
    return DynCreateReserveState(
      reserveInfoState: reserveInfoState ?? this.reserveInfoState,
      subType: subType ?? this.subType,
      title: title ?? this.title,
      date: date ?? this.date,
      canCreate: canCreate ?? this.canCreate,
    );
  }
}

/// Dynamics create reserve controller (Riverpod version)
@riverpod
class DynCreateReserveController extends _$DynCreateReserveController {
  final DateTime now = DateTime.now();
  late final DateTime end = now.copyWith(day: now.day + 90);

  @override
  DynCreateReserveState build(int? sid) {
    final state = DynCreateReserveState(
      reserveInfoState: LoadingState.loading(),
      date: DateTime.now().copyWith(hour: 20, minute: 0),
    );

    // Load initial data if editing
    if (sid != null) {
      Future.microtask(() => queryData(sid));
    }

    return state;
  }

  /// Update sub type
  void updateSubType(int subType) {
    state = state.copyWith(subType: subType);
  }

  /// Update title
  void updateTitle(String title) {
    state = state.copyWith(
      title: title,
      canCreate: title.trim().isNotEmpty,
    );
  }

  /// Update date
  void updateDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  /// Query reserve info for editing
  Future<void> queryData(int? sid) async {
    if (sid == null) return;
    final getReserveInfo = ref.read(getReserveInfoUseCaseProvider);
    final result = await getReserveInfo(sid: sid);
    if (result case Success(:final response)) {
      state = state.copyWith(
        reserveInfoState: result,
        title: response.title,
        date: DateTime.fromMillisecondsSinceEpoch(
          response.livePlanStartTime! * 1000,
        ),
        canCreate: true,
      );
    } else {
      state = state.copyWith(reserveInfoState: result);
    }
  }

  /// Create or update reserve
  Future<LoadingState<dynamic>> onCreate(int? sid) async {
    final livePlanStartTime = state.date.millisecondsSinceEpoch ~/ 1000;

    if (sid == null) {
      final createReserve = ref.read(createReserveUseCaseProvider);
      final result = await createReserve(
        title: state.title,
        subType: state.subType,
        livePlanStartTime: livePlanStartTime,
      );
      return result;
    } else {
      final updateReserve = ref.read(updateReserveUseCaseProvider);
      final result = await updateReserve(
        sid: sid!,
        subType: state.subType,
        title: state.title,
        livePlanStartTime: livePlanStartTime,
      );
      return result;
    }
  }
}
