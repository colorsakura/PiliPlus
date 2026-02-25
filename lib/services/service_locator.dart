import 'package:PiliPlus/features/live_room/data/datasources/live_websocket_datasource_impl.dart';
import 'package:PiliPlus/features/live_room/data/repositories/live_stream_repository_impl.dart';
import 'package:PiliPlus/features/live_room/domain/repositories/live_stream_repository.dart';
import 'package:PiliPlus/services/audio_handler.dart';
import 'package:PiliPlus/services/audio_session.dart';

VideoPlayerServiceHandler? videoPlayerServiceHandler;
AudioSessionHandler? audioSessionHandler;

/// LiveStreamDataSource实例
LiveWebSocketDatasourceImpl? liveWebSocketDataSource;

/// LiveStreamRepository实例
LiveStreamRepository? liveStreamRepository;

Future<void> setupServiceLocator() async {
  final audio = await initAudioService();
  videoPlayerServiceHandler = audio;
  audioSessionHandler = AudioSessionHandler();

  // 初始化WebSocket相关依赖
  liveWebSocketDataSource = LiveWebSocketDatasourceImpl();
  liveStreamRepository = LiveStreamRepositoryImpl(liveWebSocketDataSource!);
}

Future<void> resetServiceLocator() async {
  await liveStreamRepository?.disconnect();
  liveWebSocketDataSource = null;
  liveStreamRepository = null;
}
