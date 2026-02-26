import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space/space_opus/data.dart';
import 'package:PiliPlus/features/member_opus/domain/entities/member_opus_params.dart';
import 'package:PiliPlus/features/member_opus/domain/repositories/member_opus_repository.dart';

/// Use case for fetching member opus list
class FetchMemberOpus {
  final MemberOpusRepository repository;

  const FetchMemberOpus(this.repository);

  Future<LoadingState<SpaceOpusData>> call(FetchMemberOpusParams params) =>
      repository.fetchMemberOpus(params);
}
