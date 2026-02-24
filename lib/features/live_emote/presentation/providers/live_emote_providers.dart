import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/live_emote/data/datasources/live_emote_remote_datasource.dart';
import 'package:PiliPlus/features/live_emote/data/repositories/live_emote_repository_impl.dart';
import 'package:PiliPlus/features/live_emote/domain/repositories/live_emote_repository.dart';
import 'package:PiliPlus/features/live_emote/domain/usecases/get_live_emoticons_usecase.dart';
import 'package:PiliPlus/features/live_emote/presentation/providers/live_emote_controller.dart';

// Remote Datasource Provider
final liveEmoteRemoteDatasourceProvider =
    Provider<LiveEmoteRemoteDatasource>((ref) {
  return const LiveEmoteRemoteDatasource();
});

// Repository Provider
final liveEmoteRepositoryProvider = Provider<LiveEmoteRepository>((ref) {
  final datasource = ref.watch(liveEmoteRemoteDatasourceProvider);
  return LiveEmoteRepositoryImpl(datasource);
});

// Use Case Provider
final getLiveEmoticonsUseCaseProvider = Provider<GetLiveEmoticonsUseCase>((ref) {
  final repository = ref.watch(liveEmoteRepositoryProvider);
  return GetLiveEmoticonsUseCase(repository);
});

// Controller Provider - uses family for different room IDs
final liveEmoteControllerProvider =
    Provider.family<LiveEmoteController, int>((ref, roomId) {
  return LiveEmoteController(
    roomId: roomId,
    getLiveEmoticonsUseCase: ref.watch(getLiveEmoticonsUseCaseProvider),
  );
});
