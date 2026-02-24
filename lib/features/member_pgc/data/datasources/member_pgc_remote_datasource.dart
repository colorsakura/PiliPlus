import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/member.dart';
import 'package:PiliPlus/models/common/member/contribute_type.dart';
import 'package:PiliPlus/models/space/space_archive/data.dart';

/// Remote datasource for member PGC data
class MemberPgcRemoteDatasource {
  const MemberPgcRemoteDatasource();

  /// Fetch space archive from API
  Future<LoadingState<SpaceArchiveData>> getSpaceArchive({
    required ContributeType type,
    required int mid,
    required int pn,
  }) =>
      MemberHttp.spaceArchive(
        type: type,
        mid: mid,
        pn: pn,
      );
}
