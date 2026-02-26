import 'package:PiliPlus/features/mine/data/datasources/mine_remote_datasource.dart';
import 'package:PiliPlus/features/mine/data/repositories/mine_repository_impl.dart';
import 'package:PiliPlus/features/mine/domain/repositories/mine_repository.dart';
import 'package:PiliPlus/features/mine/domain/usecases/get_fav_folders.dart';
import 'package:PiliPlus/features/mine/domain/usecases/get_user_info.dart';
import 'package:PiliPlus/features/mine/domain/usecases/get_user_stat.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 我的页面远程数据源 Provider
final mineRemoteDataSourceProvider = Provider<MineRemoteDataSource>((ref) {
  return MineRemoteDataSource();
});

/// 我的页面仓库实现 Provider
final mineRepositoryProvider = Provider<MineRepository>((ref) {
  final remoteDataSource = ref.watch(mineRemoteDataSourceProvider);
  return MineRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

/// 获取用户信息用例 Provider
final getUserInfoUseCaseProvider = Provider<GetUserInfoUseCase>((ref) {
  final repository = ref.watch(mineRepositoryProvider);
  return GetUserInfoUseCase(repository);
});

/// 获取用户统计信息用例 Provider
final getUserStatUseCaseProvider = Provider<GetUserStatUseCase>((ref) {
  final repository = ref.watch(mineRepositoryProvider);
  return GetUserStatUseCase(repository);
});

/// 获取收藏夹列表用例 Provider
final getFavFoldersUseCaseProvider = Provider<GetFavFoldersUseCase>((ref) {
  final repository = ref.watch(mineRepositoryProvider);
  return GetFavFoldersUseCase(repository);
});
