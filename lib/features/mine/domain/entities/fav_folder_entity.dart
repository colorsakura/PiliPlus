import 'package:PiliPlus/models/fav/fav_folder/data.dart';

/// 收藏夹实体
///
/// 包含收藏夹的基本信息
class FavFolderEntity {
  /// 收藏夹ID
  final int? fid;

  /// 收藏夹名称
  final String? title;

  /// 收藏夹封面
  final String? cover;

  /// 收藏数量
  final int? mediaCount;

  const FavFolderEntity({
    this.fid,
    this.title,
    this.cover,
    this.mediaCount,
  });

  FavFolderEntity copyWith({
    int? fid,
    String? title,
    String? cover,
    int? mediaCount,
  }) {
    return FavFolderEntity(
      fid: fid ?? this.fid,
      title: title ?? this.title,
      cover: cover ?? this.cover,
      mediaCount: mediaCount ?? this.mediaCount,
    );
  }

  /// 从模型创建实体
  factory FavFolderEntity.fromModel(dynamic item) {
    return FavFolderEntity(
      fid: item.id,
      title: item.title,
      cover: item.cover,
      mediaCount: item.mediaCount,
    );
  }
}

/// 收藏夹列表实体
///
/// 包含收藏夹列表和总数
class FavFolderListEntity {
  /// 收藏夹列表
  final List<FavFolderEntity> list;

  /// 收藏夹总数
  final int? totalCount;

  const FavFolderListEntity({
    this.list = const [],
    this.totalCount,
  });

  FavFolderListEntity copyWith({
    List<FavFolderEntity>? list,
    int? totalCount,
  }) {
    return FavFolderListEntity(
      list: list ?? this.list,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  /// 从模型创建实体
  factory FavFolderListEntity.fromModel(FavFolderData model) {
    final list = model.list?.map((item) => FavFolderEntity.fromModel(item)).toList() ?? [];
    return FavFolderListEntity(
      list: list,
      totalCount: model.count,
    );
  }
}
