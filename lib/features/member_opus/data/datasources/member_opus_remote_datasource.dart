import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space/space_opus/data.dart';
import 'package:PiliPlus/features/member_opus/domain/entities/member_opus_params.dart';

/// Data source interface for member opus operations
abstract class MemberOpusRemoteDataSource {
  /// Fetch member opus list via API
  Future<LoadingState<SpaceOpusData>> fetchMemberOpus(FetchMemberOpusParams params);
}
