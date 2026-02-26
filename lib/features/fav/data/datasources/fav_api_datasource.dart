/// 收藏远程数据源
///
/// 负责所有收藏相关的网络请求
library;

// 忽略类型推断警告
// ignore_for_file: prefer_collection_literals, map_value_type_not_assignable

import 'package:PiliPlus/core/network/http_client.dart';
import 'package:PiliPlus/core/constants/fav_api_constants.dart';
import 'package:PiliPlus/core/errors/error_handler.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/models/common/fav_order_type.dart';
import 'package:PiliPlus/models/fav/fav_article/data.dart';
import 'package:PiliPlus/models/fav/fav_detail/data.dart';
import 'package:PiliPlus/models/fav/fav_folder/data.dart';
import 'package:PiliPlus/models/fav/fav_folder/list.dart';
import 'package:PiliPlus/models/fav/fav_note/list.dart';
import 'package:PiliPlus/models/fav/fav_pgc/data.dart';
import 'package:PiliPlus/models/fav/fav_topic/data.dart';
import 'package:PiliPlus/models/space/space_cheese/data.dart';
import 'package:PiliPlus/models/space/space_fav/data.dart';
import 'package:PiliPlus/models/sub/sub_detail/data.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:dio/dio.dart';

/// 收藏远程数据源
class FavRemoteDataSource {
  final Dio _httpClient = HttpClientManager.instance;

  /// 收藏收藏夹
  ///
  /// [mediaId] 收藏夹ID
  Future<void> favFavFolder(Object mediaId) async {
    try {
      final response = await _httpClient.post(
        FavApiConstants.favFavFolder,
        data: {
          'media_id': mediaId,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '收藏收藏夹失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 取消收藏收藏夹
  ///
  /// [mediaId] 收藏夹ID
  Future<void> unfavFavFolder(Object mediaId) async {
    try {
      final response = await _httpClient.post(
        FavApiConstants.unfavFavFolder,
        data: {
          'media_id': mediaId,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '取消收藏收藏夹失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 用户收藏夹详情
  ///
  /// [mediaId] 收藏夹ID
  /// [pn] 页码
  /// [ps] 每页数量
  /// [keyword] 关键词
  /// [order] 排序方式
  /// [type] 类型：0-全部，1-视频，2-文章，12-音频，21-番剧
  Future<FavDetailData> userFavFolderDetail({
    required int mediaId,
    required int pn,
    required int ps,
    String keyword = '',
    FavOrderType order = FavOrderType.mtime,
    int type = 0,
  }) async {
    try {
      final response = await _httpClient.get(
        FavApiConstants.favResourceList,
        queryParameters: {
          'media_id': mediaId,
          'pn': pn,
          'ps': ps,
          'keyword': keyword,
          'order': order.name,
          'type': type,
          'tid': 0,
          'platform': 'web',
        },
      );
      if (response.data['code'] == 0) {
        return FavDetailData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取收藏夹详情失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 取消订阅
  ///
  /// [id] ID
  /// [type] 类型：11-收藏夹，其他-番剧
  Future<void> cancelSub({
    required int id,
    required int type,
  }) async {
    try {
      final endpoint = type == 11
          ? FavApiConstants.unfavFolder
          : FavApiConstants.unfavSeason;

      final response = await _httpClient.post(
        endpoint,
        data: type == 11
            ? {
                'media_id': id,
                'csrf': Accounts.main.csrf,
              }
            : {
                'platform': 'web',
                'season_id': id,
                'csrf': Accounts.main.csrf,
              },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '取消订阅失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 收藏番剧列表
  ///
  /// [vmid] 用户ID
  /// [pn] 页码
  /// [ps] 每页数量
  Future<SubDetailData> favSeasonList({
    int? vmid,
    int? pn,
    int? ps,
  }) async {
    try {
      final response = await _httpClient.get(
        FavApiConstants.favSeasonList,
        queryParameters: {
          if (vmid != null) 'vmid': vmid,
          if (pn != null) 'pn': pn,
          if (ps != null) 'ps': ps,
        },
      );
      if (response.data['code'] == 0) {
        return SubDetailData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取收藏番剧列表失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 收藏课程列表
  ///
  /// [mid] 用户ID
  /// [pn] 页码
  /// [ps] 每页数量
  Future<SpaceCheeseData> favPugv({
    required int mid,
    int? pn,
    int? ps,
  }) async {
    try {
      final response = await _httpClient.get(
        FavApiConstants.favPugv,
        queryParameters: {
          'mid': mid,
          if (pn != null) 'pn': pn,
          if (ps != null) 'ps': ps,
          'platform': 'web',
        },
      );
      if (response.data['code'] == 0) {
        return SpaceCheeseData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取收藏课程列表失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 添加收藏课程
  ///
  /// [seasonId] 课程ID
  Future<void> addFavPugv(Object seasonId) async {
    try {
      final response = await _httpClient.post(
        FavApiConstants.addFavPugv,
        data: {
          'season_id': seasonId,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '添加收藏课程失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 删除收藏课程
  ///
  /// [seasonId] 课程ID
  Future<void> delFavPugv(Object seasonId) async {
    try {
      final response = await _httpClient.post(
        FavApiConstants.delFavPugv,
        data: {
          'season_id': seasonId,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '删除收藏课程失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 收藏话题列表
  ///
  /// [pn] 页码
  /// [ps] 每页数量
  Future<FavTopicData> favTopic({
    int? pn,
    int? ps,
  }) async {
    try {
      final response = await _httpClient.get(
        FavApiConstants.favTopicList,
        queryParameters: {
          if (pn != null) 'pn': pn,
          if (ps != null) 'ps': ps,
          'platform': 'web',
        },
      );
      if (response.data['code'] == 0) {
        return FavTopicData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取收藏话题列表失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 添加收藏话题
  ///
  /// [topicId] 话题ID
  Future<void> addFavTopic(Object topicId) async {
    try {
      final response = await _httpClient.post(
        FavApiConstants.addFavTopic,
        data: {
          'topic_id': topicId,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '添加收藏话题失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 删除收藏话题
  ///
  /// [topicId] 话题ID
  Future<void> delFavTopic(Object topicId) async {
    try {
      final response = await _httpClient.post(
        FavApiConstants.delFavTopic,
        data: {
          'topic_id': topicId,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '删除收藏话题失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 点赞话题
  ///
  /// [topicId] 话题ID
  /// [isLike] 是否点赞
  Future<void> likeTopic({
    required Object topicId,
    required bool isLike,
  }) async {
    try {
      final response = await _httpClient.post(
        FavApiConstants.likeTopic,
        data: {
          'topic_id': topicId,
          'type': isLike ? 1 : 2,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '点赞话题失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 收藏的文章列表
  ///
  /// [pn] 页码
  Future<FavArticleData> favArticle({
    int? pn,
  }) async {
    try {
      final response = await _httpClient.get(
        FavApiConstants.favArticle,
        queryParameters: {
          if (pn != null) 'pn': pn,
          'ps': 20,
        },
      );
      if (response.data['code'] == 0) {
        return FavArticleData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取收藏文章列表失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 添加收藏文章
  ///
  /// [id] 文章ID
  /// [mid] UP主ID
  Future<void> addFavArticle({
    required int id,
    required int mid,
  }) async {
    try {
      final response = await _httpClient.post(
        FavApiConstants.addFavArticle,
        data: {
          'id': id,
          'mid': mid,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '添加收藏文章失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 删除收藏文章
  ///
  /// [id] 文章ID
  Future<void> delFavArticle({
    required int id,
  }) async {
    try {
      final response = await _httpClient.post(
        FavApiConstants.delFavArticle,
        data: {
          'id': id,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '删除收藏文章失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 用户笔记列表
  ///
  /// [pn] 页码
  Future<List<FavNoteItemModel>?> userNoteList({
    int? pn,
  }) async {
    try {
      final response = await _httpClient.get(
        FavApiConstants.userNoteList,
        queryParameters: {
          'pn': pn ?? 1,
          'ps': 20,
        },
      );
      if (response.data['code'] == 0) {
        return (response.data['data']['notes'] as List?)
            ?.map((e) => FavNoteItemModel.fromJson(e))
            .toList();
      } else {
        throw ServerException(
          response.data['message'] ?? '获取用户笔记列表失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 笔记列表
  ///
  /// [oid] 对象ID
  /// [oidType] 对象类型
  /// [pn] 页码
  Future<List<FavNoteItemModel>?> noteList({
    required int oid,
    required int oidType,
    int? pn,
  }) async {
    try {
      final response = await _httpClient.get(
        FavApiConstants.noteList,
        queryParameters: {
          'oid': oid,
          'oid_type': oidType,
          'pn': pn ?? 1,
          'ps': 5,
        },
      );
      if (response.data['code'] == 0) {
        return (response.data['data']['notes'] as List?)
            ?.map((e) => FavNoteItemModel.fromJson(e))
            .toList();
      } else {
        throw ServerException(
          response.data['message'] ?? '获取笔记列表失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 删除笔记
  ///
  /// [noteId] 笔记ID
  /// [isPublish] 是否已发布
  Future<void> delNote({
    required int noteId,
    bool isPublish = false,
  }) async {
    try {
      final response = await _httpClient.post(
        isPublish ? FavApiConstants.delPublishNote : FavApiConstants.delNote,
        data: {
          'note_id': noteId,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '删除笔记失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 收藏PGC（番剧/影视）
  ///
  /// [vmid] 用户ID
  /// [pn] 页码
  /// [ps] 每页数量
  Future<FavPgcData> favPgc({
    int? vmid,
    int? pn,
    int? ps,
  }) async {
    try {
      final response = await _httpClient.get(
        FavApiConstants.favPgc,
        queryParameters: {
          if (vmid != null) 'vmid': vmid,
          if (pn != null) 'pn': pn,
          if (ps != null) 'ps': ps,
        },
      );
      if (response.data['code'] == 0) {
        return FavPgcData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取收藏PGC失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 用户创建的收藏夹列表
  ///
  /// [pn] 页码
  /// [ps] 每页数量
  Future<FavFolderData> userfavFolder({
    int? pn,
    int? ps,
  }) async {
    try {
      final response = await _httpClient.get(
        FavApiConstants.userFavFolder,
        queryParameters: {
          if (pn != null) 'pn': pn,
          if (ps != null) 'ps': ps,
          'up_mid': Accounts.main.mid,
        },
      );
      if (response.data['code'] == 0) {
        return FavFolderData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取收藏夹列表失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 排序收藏夹
  ///
  /// [folderIdList] 收藏夹ID列表
  Future<void> sortFavFolder({
    required List<int> folderIdList,
  }) async {
    try {
      final response = await _httpClient.post(
        FavApiConstants.sortFavFolder,
        data: {
          'folder_id_list': folderIdList.join(','),
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '排序收藏夹失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 排序收藏
  ///
  /// [mediaId] 收藏夹ID
  /// [fidList] 收藏ID列表
  Future<void> sortFav({
    required int mediaId,
    required List<int> fidList,
  }) async {
    try {
      final response = await _httpClient.post(
        FavApiConstants.sortFav,
        data: {
          'media_id': mediaId,
          'fid_list': fidList.join(','),
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '排序收藏失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 清理失效收藏
  ///
  /// [mediaId] 收藏夹ID
  Future<void> cleanFav({
    required int mediaId,
  }) async {
    try {
      final response = await _httpClient.post(
        FavApiConstants.cleanFav,
        data: {
          'media_id': mediaId,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '清理收藏失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 删除收藏夹
  ///
  /// [mediaId] 收藏夹ID
  Future<void> deleteFolder({
    required int mediaId,
  }) async {
    try {
      final response = await _httpClient.post(
        FavApiConstants.deleteFolder,
        data: {
          'media_id': mediaId,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '删除收藏夹失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 添加或编辑收藏夹
  ///
  /// [isAdd] 是否添加
  /// [title] 标题
  /// [intro] 简介
  /// [privacy] 隐私设置：0-公开，1-不公开
  /// [mediaId] 收藏夹ID（编辑时需要）
  Future<FavFolderInfo> addOrEditFolder({
    required bool isAdd,
    required String title,
    String? intro,
    int? privacy,
    int? mediaId,
  }) async {
    try {
      final response = await _httpClient.post(
        isAdd ? FavApiConstants.addFolder : FavApiConstants.editFolder,
        data: {
          if (mediaId != null) 'mediaId': mediaId,
          'title': title,
          'intro': intro ?? '',
          'privacy': privacy ?? 0,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] == 0) {
        return FavFolderInfo.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '添加或编辑收藏夹失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 收藏夹信息
  ///
  /// [mediaId] 收藏夹ID
  Future<FavFolderInfo> favFolderInfo({
    required int mediaId,
  }) async {
    try {
      final response = await _httpClient.get(
        FavApiConstants.favFolderInfo,
        queryParameters: {
          'media_id': mediaId,
        },
      );
      if (response.data['code'] == 0) {
        return FavFolderInfo.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取收藏夹信息失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 收藏番剧
  ///
  /// [seasonId] 番剧ID
  /// [isFav] 是否收藏
  Future<void> seasonFav({
    required int seasonId,
    required bool isFav,
  }) async {
    try {
      final response = await _httpClient.post(
        isFav ? FavApiConstants.favSeason : FavApiConstants.unfavSeason,
        data: {
          'season_id': seasonId,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '收藏番剧失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 用户空间收藏夹
  ///
  /// [mid] 用户ID
  /// [pn] 页码
  /// [ps] 每页数量
  Future<List<SpaceFavData>?> spaceFav({
    required int mid,
    int? pn,
    int? ps,
  }) async {
    try {
      final response = await _httpClient.get(
        FavApiConstants.spaceFav,
        queryParameters: {
          'vmid': mid,
          if (pn != null) 'pn': pn,
          if (ps != null) 'ps': ps,
        },
      );
      if (response.data['code'] == 0) {
        return (response.data['data']['list'] as List?)
            ?.map((e) => SpaceFavData.fromJson(e))
            .toList();
      } else {
        throw ServerException(
          response.data['message'] ?? '获取空间收藏夹失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 社区互动
  ///
  /// [mid] UP主ID
  /// [fid] 内容ID
  /// [type] 类型
  /// [isLike] 是否点赞
  Future<void> communityAction({
    required int mid,
    required String fid,
    required int type,
    required bool isLike,
  }) async {
    try {
      final response = await _httpClient.post(
        FavApiConstants.communityAction,
        data: {
          'mid': mid,
          'fid': fid,
          'type': type,
          'action': isLike ? 1 : 2,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '社区互动失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 收藏视频
  ///
  /// [mediaId] 收藏夹ID
  /// [ids] 视频ID列表
  Future<void> favVideo({
    required int mediaId,
    required List<int> ids,
  }) async {
    try {
      final response = await _httpClient.post(
        FavApiConstants.favVideo,
        data: {
          'media_id': mediaId,
          'ids': ids.join(','),
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '收藏视频失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 取消收藏所有
  ///
  /// [mediaId] 收藏夹ID
  Future<void> unfavAll({
    required int mediaId,
  }) async {
    try {
      final response = await _httpClient.post(
        FavApiConstants.unfavAll,
        data: {
          'media_id': mediaId,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '取消收藏所有失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 复制或移动收藏
  ///
  /// [mediaId] 收藏夹ID
  /// [ids] 内容ID列表
  /// [targetMediaId] 目标收藏夹ID
  /// [isCopy] true-复制，false-移动
  /// [toView] true-到稍后再看，false-到收藏夹
  Future<void> copyOrMoveFav({
    required int mediaId,
    required List<int> ids,
    required int targetMediaId,
    required bool isCopy,
    bool toView = false,
  }) async {
    try {
      final endpoint = toView
          ? (isCopy ? FavApiConstants.copyToview : FavApiConstants.moveToview)
          : (isCopy ? FavApiConstants.copyFav : FavApiConstants.moveFav);

      final response = await _httpClient.post(
        endpoint,
        data: {
          'media_id': mediaId,
          'ids': ids.join(','),
          if (!toView) 'target_media_id': targetMediaId,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '复制或移动收藏失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 所有收藏夹列表
  ///
  /// [mid] 用户ID
  Future<FavFolderData> allFavFolders(Object mid) async {
    try {
      final response = await _httpClient.get(
        FavApiConstants.favFolder,
        queryParameters: {
          'up_mid': mid,
        },
      );
      if (response.data['code'] == 0) {
        return FavFolderData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取所有收藏夹列表失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 视频在收藏夹中
  ///
  /// [mid] 用户ID
  /// [bvid] 视频BVID
  Future<FavFolderData> videoInFolder({
    required int mid,
    required String bvid,
  }) async {
    try {
      final response = await _httpClient.get(
        FavApiConstants.favFolder,
        queryParameters: {
          'up_mid': mid,
          'bvid': bvid,
        },
      );
      if (response.data['code'] == 0) {
        return FavFolderData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取视频在收藏夹中失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
