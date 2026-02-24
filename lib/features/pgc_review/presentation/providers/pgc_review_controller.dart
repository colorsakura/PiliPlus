import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/pgc_review_type.dart';
import 'package:PiliPlus/models/pgc/pgc_review/data.dart';
import 'package:PiliPlus/models/pgc/pgc_review/list.dart';
import 'package:PiliPlus/core/controllers/common_list_controller_v2.dart';
import 'package:PiliPlus/features/pgc_review/domain/repositories/pgc_review_repository.dart';

/// Controller for PGC review page (Clean Architecture with Riverpod)
///
/// Manages PGC reviews with cursor-based pagination
class PgcReviewController extends CommonListControllerV2<PgcReviewData, PgcReviewItemModel> {
  PgcReviewController({
    required this.type,
    required this.mediaId,
    required PgcReviewRepository repository,
  })  : _repository = repository,
        _sortType = PgcReviewSortType.def {
    queryData();
  }

  final PgcReviewType type;
  final dynamic mediaId;
  final PgcReviewRepository _repository;

  int? count;
  String? next;
  PgcReviewSortType _sortType;

  PgcReviewSortType get sortType => _sortType;

  @override
  Future<void> onRefresh() {
    next = null;
    return super.onRefresh();
  }

  @override
  void checkIsEnd(int length) {
    if (count != null && length >= count!) {
      isEnd = true;
    }
  }

  @override
  List<PgcReviewItemModel>? getDataList(PgcReviewData response) {
    if (type == PgcReviewType.long &&
        _sortType == PgcReviewSortType.latest) {
      count = null;
    } else {
      count = response.count;
    }
    next = response.next;

    return response.list;
  }

  @override
  Future<LoadingState<PgcReviewData>> customGetData() =>
      _repository.getPgcReview(
        type: type,
        mediaId: mediaId,
        next: next,
        sort: _sortType.sort,
      );

  /// Like a review
  Future<void> onLike(PgcReviewItemModel item, bool isLike, reviewId) async {
    final res = await _repository.likeReview(
      mediaId: mediaId,
      reviewId: reviewId,
    );
    if (res.isSuccess) {
      int likes = item.stat?.likes ?? 0;
      item.stat
        ?..liked = isLike ? 0 : 1
        ..likes = isLike ? likes - 1 : likes + 1;
      if (!isLike) {
        item.stat?.disliked = 0;
      }
      notifyListeners();
    }
  }

  /// Dislike a review
  Future<void> onDislike(PgcReviewItemModel item, bool isDislike, reviewId) async {
    final res = await _repository.dislikeReview(
      mediaId: mediaId,
      reviewId: reviewId,
    );
    if (res.isSuccess) {
      item.stat?.disliked = isDislike ? 0 : 1;
      if (!isDislike) {
        if (item.stat?.liked == 1) {
          item.stat!.likes = item.stat!.likes! - 1;
        }
        item.stat?.liked = 0;
      }
      notifyListeners();
    }
  }

  /// Delete a review
  Future<void> onDel(int index, int reviewId) async {
    final res = await _repository.deleteReview(
      mediaId: mediaId,
      reviewId: reviewId,
    );
    if (res.isSuccess && loadingState is Success) {
      final currentList = (loadingState as Success<List<PgcReviewItemModel>?>).response;
      if (currentList != null) {
        final newList = List<PgcReviewItemModel>.from(currentList)..removeAt(index);
        loadingState = Success(newList);
      }
    }
  }

  /// Toggle sort type and reload
  void queryBySort() {
    if (isLoading) return;
    _sortType = _sortType == PgcReviewSortType.def
        ? PgcReviewSortType.latest
        : PgcReviewSortType.def;
    onReload();
  }
}
