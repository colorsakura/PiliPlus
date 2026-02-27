/// 成员远程数据源
///
/// 负责所有成员相关的网络请求
library;

// 忽略类型推断警告
// ignore_for_file: prefer_collection_literals, map_value_type_not_assignable

import 'package:PiliPlus/core/network/http_client.dart';
import 'package:PiliPlus/core/constants/member_api_constants.dart';
import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/core/errors/error_handler.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/models/common/member/contribute_type.dart';
import 'package:PiliPlus/models/dynamics/result.dart';
import 'package:PiliPlus/models/follow/data.dart';
import 'package:PiliPlus/models/member/coin_like_arc/data.dart';
import 'package:PiliPlus/models/member/info.dart';
import 'package:PiliPlus/models/member/search_archive/data.dart';
import 'package:PiliPlus/models/member/tags.dart';
import 'package:PiliPlus/models/member_card_info/data.dart';
import 'package:PiliPlus/models/space/space/data.dart';
import 'package:PiliPlus/models/space/space_archive/data.dart';
import 'package:PiliPlus/models/space/space_article/data.dart';
import 'package:PiliPlus/models/space/space_audio/data.dart';
import 'package:PiliPlus/models/space/space_cheese/data.dart';
import 'package:PiliPlus/models/space/space_opus/data.dart';
import 'package:PiliPlus/models/space/space_season_series/item.dart';
import 'package:PiliPlus/models/space/space_shop/data.dart';
import 'package:PiliPlus/models/upower_rank/data.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:PiliPlus/utils/wbi_sign.dart';
import 'package:PiliPlus/http/browser_ua.dart';
import 'package:dio/dio.dart';

/// 成员远程数据源
class MemberRemoteDataSource {
  final Dio _httpClient = HttpClientManager.instance;

  /// 举报成员
  ///
  /// [mid] 成员ID
  /// [reason] 举报原因
  /// [reasonV2] 举报原因V2
  Future<void> reportMember(
    dynamic mid, {
    String? reason,
    int? reasonV2,
  }) async {
    try {
      final response = await _httpClient.post(
        MemberApiConstants.reportMember,
        data: {
          'mid': mid,
          'reason': reason,
          'reason_v2': reasonV2,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['status'] != true) {
        throw ServerException(
          '举报失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 用户空间文章
  ///
  /// [mid] 用户ID
  /// [page] 页码
  Future<SpaceArticleData> spaceArticle({
    required int mid,
    required int page,
  }) async {
    try {
      final response = await _httpClient.get(
        MemberApiConstants.spaceArticle,
        queryParameters: {
          'build': 8430300,
          'channel': 'master',
          'version': '8.43.0',
          'c_locale': 'zh_CN',
          'mobi_app': 'android',
          'platform': 'android',
          'pn': page,
          'ps': 10,
          's_locale': 'zh_CN',
          'statistics': Constants.statisticsApp,
          'vmid': mid,
        },
        options: Options(
          headers: {
            'bili-http-engine': 'cronet',
            'user-agent': Constants.userAgentApp,
          },
        ),
      );
      if (response.data['code'] == 0) {
        return SpaceArticleData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取空间文章失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 用户空间番剧/系列列表
  ///
  /// [mid] 用户ID
  /// [pn] 页码
  Future<SpaceSsData> seasonSeriesList({
    required int? mid,
    required int pn,
  }) async {
    try {
      final response = await _httpClient.get(
        MemberApiConstants.seasonSeries,
        queryParameters: {
          'mid': mid,
          'page_num': pn,
          'page_size': 10,
        },
      );
      if (response.data['code'] == 0) {
        return SpaceSsData.fromJson(
          response.data['data']?['items_lists'] ?? {},
        );
      } else {
        throw ServerException(
          response.data['message'] ?? '获取番剧系列列表失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 用户空间投稿
  ///
  /// [type] 投稿类型
  /// [mid] 用户ID
  /// [aid] 视频AID
  /// [order] 排序方式
  /// [sort] 排序字段
  /// [pn] 页码
  /// [next] 下一页
  /// [seasonId] 番剧ID
  /// [seriesId] 系列ID
  /// [includeCursor] 是否包含游标
  Future<SpaceArchiveData> spaceArchive({
    required ContributeType type,
    required int? mid,
    String? aid,
    String? order,
    String? sort,
    int? pn,
    int? next,
    int? seasonId,
    int? seriesId,
    bool? includeCursor,
  }) async {
    try {
      final params = {
        'aid': aid,
        'build': 8430300,
        'version': '8.43.0',
        'c_locale': 'zh_CN',
        'channel': 'master',
        'mobi_app': 'android',
        'platform': 'android',
        's_locale': 'zh_CN',
        'ps': 20,
        'pn': pn,
        'next': next,
        'season_id': seasonId,
        'series_id': seriesId,
        'qn': type == ContributeType.video ? 80 : 32,
        'order': order,
        'sort': sort,
        'include_cursor': includeCursor,
        'statistics': Constants.statisticsApp,
        'vmid': mid,
      };

      final endpoint = switch (type) {
        ContributeType.video => MemberApiConstants.spaceArchive,
        ContributeType.charging => MemberApiConstants.spaceChargingArchive,
        ContributeType.season => MemberApiConstants.spaceSeason,
        ContributeType.series => MemberApiConstants.spaceSeries,
        ContributeType.bangumi => MemberApiConstants.spaceBangumi,
        ContributeType.comic => MemberApiConstants.spaceComic,
      };

      final response = await _httpClient.get(
        endpoint,
        queryParameters: params,
        options: Options(
          headers: {
            'bili-http-engine': 'cronet',
            'user-agent': Constants.userAgentApp,
          },
        ),
      );
      if (response.data['code'] == 0) {
        return SpaceArchiveData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取空间投稿失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 用户空间音频
  ///
  /// [page] 页码
  /// [mid] 用户ID
  Future<SpaceAudioData> spaceAudio({
    required int page,
    required int mid,
  }) async {
    try {
      final response = await _httpClient.get(
        MemberApiConstants.spaceAudio,
        queryParameters: {
          'pn': page,
          'ps': 20,
          'order': 1,
          'uid': mid,
          'web_location': 333.1387,
        },
      );
      if (response.data['code'] == 0) {
        return SpaceAudioData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取空间音频失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 用户空间课程
  ///
  /// [page] 页码
  /// [mid] 用户ID
  Future<SpaceCheeseData> spaceCheese({
    required int page,
    required int mid,
  }) async {
    try {
      final response = await _httpClient.get(
        MemberApiConstants.spaceCheese,
        queryParameters: {
          'pn': page,
          'ps': 30,
          'mid': mid,
          'web_location': 333.1387,
        },
      );
      if (response.data['code'] == 0) {
        return SpaceCheeseData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取空间课程失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 用户空间信息
  ///
  /// [mid] 用户ID
  /// [fromViewAid] 来源视频AID
  Future<SpaceData> space({
    int? mid,
    dynamic fromViewAid,
  }) async {
    try {
      final params = {
        'build': 8430300,
        'version': '8.43.0',
        'c_locale': 'zh_CN',
        'channel': 'master',
        'mobi_app': 'android',
        'platform': 'android',
        's_locale': 'zh_CN',
        'from_view_aid': fromViewAid,
        'statistics': Constants.statisticsApp,
        'vmid': mid,
      };
      final response = await _httpClient.get(
        MemberApiConstants.space,
        queryParameters: params,
        options: Options(
          headers: {
            'bili-http-engine': 'cronet',
            'user-agent': Constants.userAgentApp,
          },
        ),
      );
      if (response.data['code'] == 0) {
        return SpaceData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取空间信息失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 成员信息
  ///
  /// [mid] 成员ID
  /// [token] token
  Future<MemberInfoModel> memberInfo({
    required int mid,
    String token = '',
  }) async {
    try {
      String dmImgStr = Utils.base64EncodeRandomString(16, 64);
      String dmCoverImgStr = Utils.base64EncodeRandomString(32, 128);
      final params = await WbiSign.makSign({
        'mid': mid,
        'token': token,
        'platform': 'web',
        'web_location': 1550101,
        'dm_img_list': '[]',
        'dm_img_str': dmImgStr,
        'dm_cover_img_str': dmCoverImgStr,
        'dm_img_inter': '{"ds":[],"wh":[0,0,0],"of":[0,0,0]}',
      });
      final response = await _httpClient.get(
        MemberApiConstants.memberInfo,
        queryParameters: params,
        options: Options(
          headers: {
            'origin': 'https://space.bilibili.com',
            'referer': 'https://space.bilibili.com/$mid/dynamic',
            'user-agent': BrowserUa.pc,
          },
        ),
      );
      if (response.data['code'] == 0) {
        return MemberInfoModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取成员信息失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 成员统计
  ///
  /// [mid] 成员ID
  Future<Map<String, dynamic>> memberStat({int? mid}) async {
    try {
      final response = await _httpClient.get(
        MemberApiConstants.userStat,
        queryParameters: {'vmid': mid},
      );
      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取成员统计失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 成员卡片信息
  ///
  /// [mid] 成员ID
  Future<MemberCardInfoData> memberCardInfo({
    int? mid,
  }) async {
    try {
      final response = await _httpClient.get(
        MemberApiConstants.memberCardInfo,
        queryParameters: {
          'mid': mid,
          'photo': false,
        },
      );
      if (response.data['code'] == 0) {
        return MemberCardInfoData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取成员卡片信息失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 搜索投稿
  ///
  /// [mid] 成员ID
  /// [keyword] 关键词
  /// [pn] 页码
  /// [ps] 每页数量
  Future<SearchArchiveData> searchArchive({
    required String mid,
    required String keyword,
    int? pn,
    int? ps,
  }) async {
    try {
      final params = <String, Object?>{
        'mid': mid,
        'keyword': keyword,
      };
      if (pn != null) params['pn'] = pn;
      if (ps != null) params['ps'] = ps;

      final response = await _httpClient.get(
        MemberApiConstants.searchArchive,
        queryParameters: await WbiSign.makSign(params.cast<String, Object>()),
      );
      if (response.data['code'] == 0) {
        return SearchArchiveData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '搜索投稿失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 成员动态
  ///
  /// [mid] 成员ID
  /// [offset] 偏移量
  /// [isVideo] 是否视频
  Future<DynamicsDataModel> memberDynamic({
    required int mid,
    String? offset,
    bool isVideo = false,
  }) async {
    try {
      final response = await _httpClient.get(
        MemberApiConstants.memberDynamic,
        queryParameters: {
          'host_mid': mid,
          'offset': offset,
          if (isVideo) ...{
            'timezone_offset': '-480',
            'features': 'itemOpusStyle,listOnlyfans',
          },
        },
      );
      if (response.data['code'] == 0) {
        return DynamicsDataModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取成员动态失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 搜索动态
  ///
  /// [mid] 成员ID
  /// [keyword] 关键词
  /// [offset] 偏移量
  Future<DynamicsDataModel> dynSearch({
    required int mid,
    required String keyword,
    String? offset,
  }) async {
    try {
      final response = await _httpClient.get(
        MemberApiConstants.dynSearch,
        queryParameters: {
          'host_mid': mid,
          'keyword': keyword,
          'offset': offset,
        },
      );
      if (response.data['code'] == 0) {
        return DynamicsDataModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '搜索动态失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 关注分组标签列表
  Future<List<MemberTagItemModel>> followUpTags() async {
    try {
      final response = await _httpClient.get(MemberApiConstants.followUpTag);
      if (response.data['code'] == 0) {
        return (response.data['data'] as List)
            .map((e) => MemberTagItemModel.fromJson(e))
            .toList();
      } else {
        throw ServerException(
          response.data['message'] ?? '获取关注分组失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 特别关注操作
  ///
  /// [fid] 关注ID
  /// [isAdd] true-添加，false-删除
  Future<void> specialAction({
    required int fid,
    required bool isAdd,
  }) async {
    try {
      final response = await _httpClient.post(
        isAdd ? MemberApiConstants.addSpecial : MemberApiConstants.delSpecial,
        queryParameters: {
          'csrf': Accounts.main.csrf,
        },
        data: {
          'fids': fid.toString(),
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '特别关注操作失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 批量添加关注
  ///
  /// [fids] 关注ID列表（逗号分隔）
  /// [tagids] 标签ID列表（逗号分隔）
  Future<void> addUsers(String fids, String tagids) async {
    try {
      final response = await _httpClient.post(
        MemberApiConstants.addUsers,
        data: {
          'fids': fids,
          'tagids': tagids,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '批量添加关注失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 关注分组
  ///
  /// [mid] 成员ID
  /// [pn] 页码
  Future<FollowData> followUpGroup({
    required int mid,
    required int pn,
  }) async {
    try {
      final response = await _httpClient.get(
        MemberApiConstants.followUpGroup,
        queryParameters: {
          'mid': mid,
          'pn': pn,
          'ps': 20,
        },
      );
      if (response.data['code'] == 0) {
        return FollowData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取关注分组失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 创建关注分组
  ///
  /// [tagName] 分组名称
  Future<void> createFollowTag(Object tagName) async {
    try {
      final response = await _httpClient.post(
        MemberApiConstants.createFollowTag,
        data: {
          'tag': tagName,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '创建关注分组失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 修改关注分组
  ///
  /// [tagid] 分组ID
  /// [tagName] 分组名称
  Future<void> updateFollowTag(
    Object tagid,
    Object tagName,
  ) async {
    try {
      final response = await _httpClient.post(
        MemberApiConstants.updateFollowTag,
        data: {
          'tagid': tagid,
          'tagname': tagName,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '修改关注分组失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 删除关注分组
  ///
  /// [tagid] 分组ID
  Future<void> delFollowTag(Object tagid) async {
    try {
      final response = await _httpClient.post(
        MemberApiConstants.delFollowTag,
        data: {
          'tagids': tagid,
          'csrf': Accounts.main.csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '删除关注分组失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 获取置顶视频
  Future<List<dynamic>?> getTopVideo() async {
    try {
      final response = await _httpClient.get(MemberApiConstants.getTopVideo);
      if (response.data['code'] == 0) {
        return response.data['data']['list'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取置顶视频失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 获取成员浏览数据
  ///
  /// [mid] 成员ID
  Future<Map<String, dynamic>> memberView({required int mid}) async {
    try {
      final response = await _httpClient.get(
        MemberApiConstants.getMemberView,
        queryParameters: {
          'mid': mid,
          'csrf': Accounts.main.csrf,
        },
      );
      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取成员浏览数据失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 搜索关注
  ///
  /// [mid] 成员ID
  /// [pn] 页码
  /// [keyword] 关键词
  Future<FollowData> getfollowSearch({
    required int mid,
    required int pn,
    String? keyword,
  }) async {
    try {
      final response = await _httpClient.get(
        MemberApiConstants.followSearch,
        queryParameters: {
          'mid': mid,
          'pn': pn,
          'ps': 20,
          'keyword': keyword,
        },
      );
      if (response.data['code'] == 0) {
        return FollowData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '搜索关注失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 用户空间动态（opus）
  ///
  /// [mid] 成员ID
  /// [offset] 偏移量
  Future<SpaceOpusData> spaceOpus({
    required int mid,
    String? offset,
  }) async {
    try {
      final response = await _httpClient.get(
        MemberApiConstants.spaceOpus,
        queryParameters: {
          'host_mid': mid,
          'offset': offset,
        },
      );
      if (response.data['code'] == 0) {
        return SpaceOpusData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取空间动态失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// UP主影响力排行
  ///
  /// [upMid] UP主ID
  /// [page] 页码
  /// [privilegeType] 特权类型
  Future<UpowerRankData> upowerRank({
    required String upMid,
    required int page,
    int? privilegeType,
  }) async {
    try {
      final response = await _httpClient.get(
        MemberApiConstants.upowerRank,
        queryParameters: {
          'up_mid': upMid,
          'pn': page,
          'ps': 100,
          'privilege_type': privilegeType,
          'mobi_app': 'web',
          'web_location': 333.1196,
          if (Accounts.main.isLogin) 'csrf': Accounts.main.csrf,
        },
      );
      if (response.data['code'] == 0) {
        return UpowerRankData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取UP主影响力排行失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 投币视频列表
  ///
  /// [mid] 成员ID
  /// [pn] 页码
  /// [ps] 每页数量
  Future<CoinLikeArcData> coinArc({
    required int mid,
    required int pn,
    int? ps,
  }) async {
    try {
      final response = await _httpClient.get(
        MemberApiConstants.coinArc,
        queryParameters: {
          'mid': mid,
          'pn': pn,
          'ps': ps,
        },
      );
      if (response.data['code'] == 0) {
        return CoinLikeArcData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取投币视频列表失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 点赞视频列表
  ///
  /// [mid] 成员ID
  /// [pn] 页码
  /// [ps] 每页数量
  Future<CoinLikeArcData> likeArc({
    required int mid,
    required int pn,
    int? ps,
  }) async {
    try {
      final response = await _httpClient.get(
        MemberApiConstants.likeArc,
        queryParameters: {
          'mid': mid,
          'pn': pn,
          'ps': ps,
        },
      );
      if (response.data['code'] == 0) {
        return CoinLikeArcData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取点赞视频列表失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 用户空间商店
  ///
  /// [mid] 成员ID
  /// [pn] 页码
  /// [ps] 每页数量
  Future<SpaceShopData> spaceShop({
    required int mid,
    required int pn,
    int? ps,
  }) async {
    try {
      final response = await _httpClient.get(
        MemberApiConstants.spaceShop,
        queryParameters: {
          'mid': mid,
          'page_no': pn,
          'page_size': ps ?? 10,
        },
      );
      if (response.data['code'] == 0) {
        return SpaceShopData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取空间商店失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
