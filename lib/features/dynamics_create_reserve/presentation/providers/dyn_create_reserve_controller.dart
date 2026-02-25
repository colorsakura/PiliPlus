import 'package:flutter/foundation.dart';
import 'package:PiliPlus/features/dynamics_create_reserve/domain/usecases/get_dyn_reserve_data.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_reserve_info/data.dart';
import 'package:PiliPlus/utils/utils.dart';

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

/// Dynamics create reserve controller
class DynCreateReserveController extends ChangeNotifier {
  final GetReserveInfoUseCase _getReserveInfoUseCase;
  final CreateReserveUseCase _createReserveUseCase;
  final UpdateReserveUseCase _updateReserveUseCase;

  final int? sid;
  final DateTime now = DateTime.now();
  late final DateTime end = now.copyWith(day: now.day + 90);

  late DynCreateReserveState _state = DynCreateReserveState(
    reserveInfoState: LoadingState.loading(),
    date: DateTime.now().copyWith(hour: 20, minute: 0),
  );

  DynCreateReserveState get state => _state;

  String get key => Utils.generateRandomString(6);

  DynCreateReserveController({
    required GetReserveInfoUseCase getReserveInfoUseCase,
    required CreateReserveUseCase createReserveUseCase,
    required UpdateReserveUseCase updateReserveUseCase,
    this.sid,
  }) : _getReserveInfoUseCase = getReserveInfoUseCase,
       _createReserveUseCase = createReserveUseCase,
       _updateReserveUseCase = updateReserveUseCase {
    // Load initial data if editing
    if (sid != null) {
      Future.microtask(() => queryData());
    }
  }

  void _updateState(DynCreateReserveState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Update sub type
  void updateSubType(int subType) {
    _updateState(_state.copyWith(subType: subType));
  }

  /// Update title
  void updateTitle(String title) {
    _updateState(
      _state.copyWith(
        title: title,
        canCreate: title.trim().isNotEmpty,
      ),
    );
  }

  /// Update date
  void updateDate(DateTime date) {
    _updateState(_state.copyWith(date: date));
  }

  /// Query reserve info for editing
  Future<void> queryData() async {
    if (sid == null) return;
    final result = await _getReserveInfoUseCase(sid: sid!);
    if (result case Success(:final response)) {
      _updateState(
        _state.copyWith(
          reserveInfoState: result,
          title: response.title,
          date: DateTime.fromMillisecondsSinceEpoch(
            response.livePlanStartTime! * 1000,
          ),
          canCreate: true,
        ),
      );
    } else {
      _updateState(_state.copyWith(reserveInfoState: result));
    }
  }

  /// Create or update reserve
  Future<LoadingState<dynamic>> onCreate() async {
    final livePlanStartTime = _state.date.millisecondsSinceEpoch ~/ 1000;

    final result = sid == null
        ? await _createReserveUseCase(
            title: _state.title,
            subType: _state.subType,
            livePlanStartTime: livePlanStartTime,
          )
        : await _updateReserveUseCase(
            sid: sid!,
            subType: _state.subType,
            title: _state.title,
            livePlanStartTime: livePlanStartTime,
          );

    return result;
  }
}
