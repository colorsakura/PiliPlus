import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/sub/sub_detail/data.dart';

/// Repository for subscription detail data
abstract class SubscriptionDetailRepository {
  /// Fetch subscription folder detail contents
  Future<LoadingState<SubDetailData>> getFavSeasonList({
    required int id,
    required int ps,
    required int pn,
  });
}
