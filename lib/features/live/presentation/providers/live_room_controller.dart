import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/live/domain/usecases/get_live_room_info.dart';
import 'package:PiliPlus/features/live/data/repositories/live_repository_impl.dart';
import 'package:PiliPlus/features/live/data/datasources/live_remote_datasource.dart';
import 'package:PiliPlus/http/loading_state.dart';

part 'live_room_controller.g.dart';

/// Provider for LiveRemoteDataSource
final liveRemoteDataSourceProvider = Provider<LiveRemoteDataSource>((ref) {
  return LiveRemoteDataSource();
});

/// Provider for LiveRepository
final liveRepositoryProvider = Provider<LiveRepositoryImpl>((ref) {
  final datasource = ref.watch(liveRemoteDataSourceProvider);
  return LiveRepositoryImpl(remoteDataSource: datasource);
});

/// Provider for GetLiveRoomInfo use case
final getLiveRoomInfoProvider = Provider<GetLiveRoomInfo>((ref) {
  final repository = ref.watch(liveRepositoryProvider);
  return GetLiveRoomInfo(repository);
});

/// Live Room state
class LiveRoomState {
  final Map<String, dynamic>? roomInfo;
  final bool isLoading;
  final String? errorMessage;

  const LiveRoomState({
    this.roomInfo,
    this.isLoading = false,
    this.errorMessage,
  });

  LiveRoomState copyWith({
    Map<String, dynamic>? roomInfo,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LiveRoomState(
      roomInfo: roomInfo ?? this.roomInfo,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Controller for managing live room information
@riverpod
class LiveRoomController extends _$LiveRoomController {
  @override
  LiveRoomState build() {
    return const LiveRoomState();
  }

  /// Fetch live room information
  Future<void> fetchRoomInfo({
    required Object roomId,
    Object? qn,
    bool onlyAudio = false,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final getRoomInfo = ref.read(getLiveRoomInfoProvider);
      final result = await getRoomInfo(
        roomId: roomId,
        qn: qn,
        onlyAudio: onlyAudio,
      );

      switch (result) {
        case Success(:final response):
          state = state.copyWith(
            roomInfo: response,
            isLoading: false,
          );
        case Error(:final errMsg):
          state = state.copyWith(
            isLoading: false,
            errorMessage: errMsg,
          );
        case Loading():
          // Still loading
          break;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Clear room info
  void clearRoomInfo() {
    state = const LiveRoomState();
  }
}
