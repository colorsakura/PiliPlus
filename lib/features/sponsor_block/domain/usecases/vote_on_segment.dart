import 'package:PiliPlus/models/common/sponsor_block/segment_type.dart';
import 'package:PiliPlus/features/sponsor_block/domain/repositories/sponsor_block_repository.dart';

/// Vote on segment use case
class VoteOnSegment {
  final SponsorBlockRepository repository;

  const VoteOnSegment(this.repository);

  Future<void> call({
    required String uuid,
    int? type,
    SegmentType? category,
  }) {
    return repository.voteOnSegment(
      uuid: uuid,
      type: type,
      category: category,
    );
  }
}
