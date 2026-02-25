import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/member/contribute_type.dart';
import 'package:PiliPlus/models/space/space/data.dart';
import 'package:PiliPlus/models/space/space_archive/data.dart';
import 'package:PiliPlus/models/space/space_archive/item.dart';
import 'package:PiliPlus/core/controllers/common_list_controller_v2.dart';
import 'package:PiliPlus/features/member_pgc/domain/repositories/member_pgc_repository.dart';

/// Controller for member PGC (bangumi) page
///
/// This demonstrates migration from GetX CommonListController to Riverpod CommonListControllerV2
class MemberPgcController
    extends CommonListControllerV2<SpaceArchiveData, SpaceArchiveItem> {
  MemberPgcController({
    required this.mid,
    required MemberPgcRepository repository,
    SpaceData? initialData,
  }) : _repository = repository {
    if (initialData != null) {
      _initializeFromCache(initialData);
    } else {
      queryData();
    }
  }

  final int mid;
  final MemberPgcRepository _repository;
  int? count;

  /// Initialize from cached SpaceData (from parent MemberController)
  void _initializeFromCache(SpaceData response) {
    if (response.season != null) {
      page = 2;
      final res = response.season!;
      loadingState = Success(res.item);
      count = res.count;
      isEnd = (res.item?.length ?? 0) >= (count ?? 0);
      notifyListeners();
    } else {
      queryData();
    }
  }

  @override
  List<SpaceArchiveItem>? getDataList(SpaceArchiveData response) {
    return response.item;
  }

  @override
  void checkIsEnd(int length) {
    if (count != null && length >= count!) {
      isEnd = true;
    }
  }

  @override
  Future<LoadingState<SpaceArchiveData>> customGetData() =>
      _repository.getSpaceArchive(
        type: ContributeType.bangumi,
        mid: mid,
        pn: page,
      );
}
