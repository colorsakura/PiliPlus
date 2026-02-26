import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space/space_opus/data.dart';
import 'package:PiliPlus/features/member_opus/domain/entities/member_opus_params.dart';

/// Repository interface for member opus operations
abstract class MemberOpusRepository {
  /// Fetch member opus list with pagination
  Future<LoadingState<SpaceOpusData>> fetchMemberOpus(FetchMemberOpusParams params);
}
