import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space/space_archive/data.dart';
import 'package:PiliPlus/features/member_video/domain/entities/member_video_params.dart';

/// Data source interface for member video operations
abstract class MemberVideoRemoteDataSource {
  /// Fetch member space archive via API
  Future<LoadingState<SpaceArchiveData>> fetchMemberArchive(FetchMemberArchiveParams params);

  /// Search video cid via API
  Future<String?> searchVideoCid(String aid, String bvid);
}
