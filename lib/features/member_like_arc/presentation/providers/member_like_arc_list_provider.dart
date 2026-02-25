import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/member/data/datasources/member_api_datasource.dart';
import 'package:PiliPlus/features/member_like_arc/data/repositories/member_like_arc_repository_impl.dart';
import 'package:PiliPlus/features/member_like_arc/domain/usecases/fetch_member_like_arcs.dart';
import 'package:PiliPlus/features/member_like_arc/presentation/providers/member_like_arc_list_controller.dart';

/// Remote data source provider
final memberApiDataSourceProvider = Provider<MemberRemoteDataSource>((ref) {
  return MemberRemoteDataSource();
});

final memberLikeArcRepositoryProvider = Provider<MemberLikeArcRepositoryImpl>((
  ref,
) {
  return MemberLikeArcRepositoryImpl(
    remoteDataSource: ref.watch(memberApiDataSourceProvider),
  );
});

final fetchMemberLikeArcsUseCaseProvider = Provider<FetchMemberLikeArcsUseCase>(
  (ref) {
    return FetchMemberLikeArcsUseCase(
      ref.watch(memberLikeArcRepositoryProvider),
    );
  },
);

final memberLikeArcListControllerProvider =
    Provider.family<MemberLikeArcListController, dynamic>((ref, mid) {
      return MemberLikeArcListController(
        mid: mid,
        fetchLikeArcs: ref.watch(fetchMemberLikeArcsUseCaseProvider),
      );
    });
