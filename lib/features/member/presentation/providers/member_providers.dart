import 'package:PiliPlus/features/member/data/datasources/member_api_datasource.dart';
import 'package:PiliPlus/features/member/data/repositories/member_repository_impl.dart';
import 'package:PiliPlus/features/member/domain/repositories/member_repository.dart';
import 'package:PiliPlus/features/member/domain/usecases/follow_member.dart';
import 'package:PiliPlus/features/member/domain/usecases/get_member_space.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 成员远程数据源 Provider
final memberRemoteDataSourceProvider = Provider<MemberRemoteDataSource>((ref) {
  return MemberRemoteDataSource();
});

/// 成员仓库实现 Provider
final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  final remoteDataSource = ref.watch(memberRemoteDataSourceProvider);
  return MemberRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

/// 获取成员空间用例 Provider
final getMemberSpaceUseCaseProvider = Provider<GetMemberSpaceUseCase>((ref) {
  final repository = ref.watch(memberRepositoryProvider);
  return GetMemberSpaceUseCase(repository);
});

/// 关注成员用例 Provider
final followMemberUseCaseProvider = Provider<FollowMemberUseCase>((ref) {
  final repository = ref.watch(memberRepositoryProvider);
  return FollowMemberUseCase(repository);
});
