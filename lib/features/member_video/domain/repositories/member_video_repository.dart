import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space/space_archive/data.dart';
import 'package:PiliPlus/features/member_video/domain/entities/member_video_params.dart';

/// Repository interface for member video operations
abstract class MemberVideoRepository {
  /// Fetch member space archive (videos/seasons/series)
  Future<LoadingState<SpaceArchiveData>> fetchMemberArchive(FetchMemberArchiveParams params);

  /// Search for video cid by aid/bvid
  Future<String?> searchVideoCid(String aid, String bvid);
}
