import 'package:PiliPlus/features/member_video/domain/entities/member_video_params.dart';
import 'package:PiliPlus/features/member_video/domain/repositories/member_video_repository.dart';

/// Use case for searching video cid
class SearchVideoCid {
  final MemberVideoRepository repository;

  const SearchVideoCid(this.repository);

  Future<String?> call(String aid, String bvid) =>
      repository.searchVideoCid(aid, bvid);
}
