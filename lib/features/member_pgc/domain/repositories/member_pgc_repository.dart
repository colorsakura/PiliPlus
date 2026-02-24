import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/member/contribute_type.dart';
import 'package:PiliPlus/models/space/space_archive/data.dart';

/// Repository for member PGC (bangumi) data
abstract class MemberPgcRepository {
  /// Fetch space archive for bangumi type
  Future<LoadingState<SpaceArchiveData>> getSpaceArchive({
    required ContributeType type,
    required int mid,
    required int pn,
  });
}
