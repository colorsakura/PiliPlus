import 'package:PiliPlus/features/emote/data/datasources/emote_remote_datasource.dart';
import 'package:PiliPlus/features/emote/data/repositories/emote_repository_impl.dart';
import 'package:PiliPlus/features/emote/domain/repositories/emote_repository.dart';
import 'package:PiliPlus/features/emote/domain/usecases/get_emote_packages.dart';
import 'package:PiliPlus/features/emote/presentation/providers/emote_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 表情远程数据源Provider
final emoteRemoteDataSourceProvider = Provider<EmoteRemoteDataSource>((ref) {
  return EmoteRemoteDataSource();
});

/// 表情仓库Provider
final emoteRepositoryProvider = Provider<EmoteRepository>((ref) {
  final remoteDataSource = ref.watch(emoteRemoteDataSourceProvider);
  return EmoteRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

/// 获取表情包用例Provider
final getEmotePackagesUseCaseProvider = Provider<GetEmotePackagesUseCase>((
  ref,
) {
  final repository = ref.watch(emoteRepositoryProvider);
  return GetEmotePackagesUseCase(repository);
});

/// 表情Controller Provider
final emoteControllerProvider = NotifierProvider<EmoteController, EmoteState>(
  EmoteController.new,
);
