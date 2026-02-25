import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/sub/sub/list.dart';
import 'package:PiliPlus/models/sub/sub_detail/data.dart';
import 'package:PiliPlus/models/sub/sub_detail/media.dart';
import 'package:PiliPlus/core/controllers/common_list_controller_v2.dart';
import 'package:PiliPlus/features/subscription_detail/domain/repositories/subscription_detail_repository.dart';

/// Controller for subscription detail page (Clean Architecture with Riverpod)
///
/// Manages subscription folder contents with pagination
class SubscriptionDetailController
    extends CommonListControllerV2<SubDetailData, SubDetailItemModel> {
  SubscriptionDetailController({
    required int id,
    required SubscriptionDetailRepository repository,
    SubItemModel? initialSubInfo,
  }) : _id = id,
       _repository = repository,
       _subInfo = initialSubInfo {
    queryData();
  }

  final int _id;
  final SubscriptionDetailRepository _repository;
  SubItemModel? _subInfo;

  /// Get subscription info (updated from API response)
  SubItemModel? get subInfo => _subInfo;

  @override
  List<SubDetailItemModel>? getDataList(SubDetailData response) {
    _subInfo = response.info;
    notifyListeners();
    return response.medias;
  }

  @override
  void checkIsEnd(int length) {
    final count = _subInfo?.mediaCount;
    if (count != null && length >= count) {
      isEnd = true;
    }
  }

  @override
  Future<LoadingState<SubDetailData>> customGetData() =>
      _repository.getFavSeasonList(
        id: _id,
        ps: 20,
        pn: page,
      );
}
