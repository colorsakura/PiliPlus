import 'package:PiliPlus/models/pgc/pgc_index_result/list.dart';

/// PGC索引项实体
class PgcIndexItemEntity {
  final int? seasonId;
  final String? title;
  final String? cover;
  final String? score;
  final String? indexShow;
  final int? isFinish;
  final int? seasonStatus;

  const PgcIndexItemEntity({
    this.seasonId,
    this.title,
    this.cover,
    this.score,
    this.indexShow,
    this.isFinish,
    this.seasonStatus,
  });

  factory PgcIndexItemEntity.fromModel(PgcIndexItem model) {
    return PgcIndexItemEntity(
      seasonId: model.seasonId,
      title: model.title,
      cover: model.cover,
      score: model.score,
      indexShow: model.indexShow,
      isFinish: model.isFinish,
      seasonStatus: model.seasonStatus,
    );
  }
}

/// PGC索引结果实体
class PgcIndexResultEntity {
  final List<PgcIndexItemEntity>? items;
  final bool? hasNext;

  const PgcIndexResultEntity({
    this.items,
    this.hasNext,
  });

  factory PgcIndexResultEntity.fromModel(PgcIndexItem? list, bool? hasNext) {
    return PgcIndexResultEntity(
      items: list == null ? null : [PgcIndexItemEntity.fromModel(list)],
      hasNext: hasNext,
    );
  }
}
