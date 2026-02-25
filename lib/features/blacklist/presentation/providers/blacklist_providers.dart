import 'package:PiliPlus/features/blacklist/data/datasources/blacklist_remote_datasource.dart';
import 'package:PiliPlus/features/blacklist/data/repositories/blacklist_repository_impl.dart';
import 'package:PiliPlus/features/blacklist/domain/repositories/blacklist_repository.dart';
import 'package:PiliPlus/features/blacklist/domain/usecases/fetch_blacklist.dart';
import 'package:PiliPlus/features/blacklist/domain/usecases/remove_from_blacklist.dart';
import 'package:PiliPlus/features/user/data/datasources/user_remote_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 黑名单远程数据源Provider
final blacklistRemoteDataSourceProvider = Provider<BlacklistRemoteDataSource>((
  ref,
) {
  return BlacklistRemoteDataSource();
});

/// 用户远程数据源Provider
final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  return UserRemoteDataSource();
});

/// 黑名单仓库Provider
final blacklistRepositoryProvider = Provider<BlacklistRepository>((ref) {
  final remoteDataSource = ref.watch(blacklistRemoteDataSourceProvider);
  final userRemoteDataSource = ref.watch(userRemoteDataSourceProvider);
  return BlacklistRepositoryImpl(
    remoteDataSource: remoteDataSource,
    userRemoteDataSource: userRemoteDataSource,
  );
});

/// 获取黑名单用例Provider
final fetchBlacklistUseCaseProvider = Provider<FetchBlacklistUseCase>((ref) {
  final repository = ref.watch(blacklistRepositoryProvider);
  return FetchBlacklistUseCase(repository);
});

/// 从黑名单移除用例Provider
final removeFromBlacklistUseCaseProvider = Provider<RemoveFromBlacklistUseCase>(
  (ref) {
    final repository = ref.watch(blacklistRepositoryProvider);
    return RemoveFromBlacklistUseCase(repository);
  },
);
