import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space/space_archive/data.dart';
import 'package:PiliPlus/features/member_video/domain/entities/member_video_params.dart';
import 'package:PiliPlus/features/member_video/domain/repositories/member_video_repository.dart';

/// Use case for fetching member space archive
class FetchMemberArchive {
  final MemberVideoRepository repository;

  const FetchMemberArchive(this.repository);

  Future<LoadingState<SpaceArchiveData>> call(FetchMemberArchiveParams params) =>
      repository.fetchMemberArchive(params);
}
