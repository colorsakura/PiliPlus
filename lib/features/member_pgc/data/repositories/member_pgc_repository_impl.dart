import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/member/contribute_type.dart';
import 'package:PiliPlus/models/space/space_archive/data.dart';
import 'package:PiliPlus/features/member_pgc/domain/repositories/member_pgc_repository.dart';
import 'package:PiliPlus/features/member_pgc/data/datasources/member_pgc_remote_datasource.dart';

/// Repository implementation for member PGC data
class MemberPgcRepositoryImpl implements MemberPgcRepository {
  const MemberPgcRepositoryImpl(this._datasource);

  final MemberPgcRemoteDatasource _datasource;

  @override
  Future<LoadingState<SpaceArchiveData>> getSpaceArchive({
    required ContributeType type,
    required int mid,
    required int pn,
  }) =>
      _datasource.getSpaceArchive(
        type: type,
        mid: mid,
        pn: pn,
      );
}
