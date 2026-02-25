/// 动态远程数据源
///
/// 负责所有动态相关的网络请求
library;

// 忽略类型推断警告
// ignore_for_file: prefer_collection_literals, map_value_type_not_assignable

import 'package:PiliPlus/core/network/http_client.dart';
import 'package:PiliPlus/core/constants/dynamics_api_constants.dart';
import 'package:PiliPlus/core/constants/api_constants.dart';
import 'package:PiliPlus/core/errors/error_handler.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/utils/wbi_sign.dart';
import 'package:dio/dio.dart';

/// 动态远程数据源
class DynamicsRemoteDataSource {
  final Dio _httpClient = HttpClientManager.instance;

  /// 关注动态列表
  Future<Map<String, dynamic>> followDynamic({
    required String type,
    String? offset,
    int? mid,
  }) async {
    try {
      final queryParams = {
        if (mid != null) 'host_mid': mid else ...{
          'type': type,
          'timezone_offset': '-480',
        },
        'offset': offset,
        'features': 'itemOpusStyle,listOnlyfans',
      };

      final response = await _httpClient.get(
        DynamicsApiConstants.followDynamic,
        queryParameters: queryParams,
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取动态列表失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 关注推荐
  Future<Map<String, dynamic>> followUp() async {
    try {
      final response = await _httpClient.get(
        DynamicsApiConstants.followUp,
        queryParameters: await WbiSign.makSign({
          'up_list_more': 1,
          'web_location': 333.1365,
        }),
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取关注推荐失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// UP主列表
  Future<Map<String, dynamic>> dynUpList(String? offset) async {
    try {
      final response = await _httpClient.get(
        DynamicsApiConstants.dynUplist,
        queryParameters: {
          'offset': offset,
          'platform': 'web',
          'web_location': 333.1365,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取UP主列表失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 动态点赞
  Future<void> thumbDynamic({
    required String? dynamicId,
    required int? up,
  }) async {
    try {
      final response = await _httpClient.post(
        DynamicsApiConstants.thumbDynamic,
        queryParameters: await WbiSign.makSign({
          'csrf': '', // 需要从外部传入
        }),
        data: {
          'dyn_id_str': dynamicId,
          'up': up,
          'spmid': '333.1365.0.0',
        },
        options: Options(
          headers: {
            'referer': ApiConstants.dynamicShareBaseUrl,
          },
        ),
      );

      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '操作失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 创建动态
  Future<Map<String, dynamic>?> createDynamic({
    dynamic mid,
    dynamic dynIdStr,
    dynamic rid,
    dynamic dynType,
    dynamic rawText,
    List? pics,
    int? publishTime,
    int? replyOption,
    int? privatePub,
    List<Map<String, dynamic>>? extraContent,
    Map<int, String>? topic,
    String? title,
    Map? attachCard,
  }) async {
    try {
      final response = await _httpClient.post(
        DynamicsApiConstants.createDynamic,
        queryParameters: {
          'platform': 'web',
          'csrf': '', // 需要从外部传入
          'x-bili-device-req-json': '{"platform": "web", "device": "pc"}',
          'x-bili-web-req-json': '{"spm_id": "333.999"}',
        },
        data: {
          "dyn_req": {
            "content": {
              "contents": [
                if (rawText != null)
                  {
                    "raw_text": rawText,
                    "type": 1,
                    "biz_id": "",
                  },
                ...?extraContent,
              ],
              if (title != null && title.isNotEmpty) 'title': title,
            },
            if (privatePub != null || replyOption != null || publishTime != null)
              "option": {
                'private_pub': privatePub,
                "timer_pub_time": publishTime,
                if (replyOption == 1) "close_comment": 1,
              },
            if (topic != null && topic.isNotEmpty)
              "topic_ids": topic.keys.toList(),
            if (attachCard != null) "attach_card": attachCard,
          },
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '创建动态失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 动态详情
  Future<Map<String, dynamic>> dynamicDetail({
    required String dynamicId,
  }) async {
    try {
      final response = await _httpClient.get(
        DynamicsApiConstants.dynamicDetail,
        queryParameters: {
          'id': dynamicId,
          'timezone_offset': '-480',
          'features': 'itemOpusStyle,listOnlyfans',
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取动态详情失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 设置置顶
  Future<void> setTop({
    required String dynamicId,
  }) async {
    try {
      final response = await _httpClient.post(
        DynamicsApiConstants.setTopDyn,
        queryParameters: {
          'csrf': '', // 需要从外部传入
        },
        data: {
          'dyn_id_str': dynamicId,
        },
      );

      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '置顶失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 取消置顶
  Future<void> rmTop({
    required String dynamicId,
  }) async {
    try {
      final response = await _httpClient.post(
        DynamicsApiConstants.rmTopDyn,
        queryParameters: {
          'csrf': '', // 需要从外部传入
        },
        data: {
          'dyn_id_str': dynamicId,
        },
      );

      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '取消置顶失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 专栏信息
  Future<Map<String, dynamic>> articleInfo({
    required String articleId,
  }) async {
    try {
      final response = await _httpClient.get(
        DynamicsApiConstants.articleInfo,
        queryParameters: {
          'id': articleId,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取专栏信息失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 专栏阅读
  Future<Map<String, dynamic>> articleView({
    required String articleId,
  }) async {
    try {
      final response = await _httpClient.get(
        DynamicsApiConstants.articleView,
        queryParameters: {
          'id': articleId,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取专栏内容失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// Opus详情
  Future<Map<String, dynamic>> opusDetail({
    required String opusId,
  }) async {
    try {
      final response = await _httpClient.get(
        DynamicsApiConstants.opusDetail,
        queryParameters: {
          'id': opusId,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取Opus详情失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 投票信息
  Future<Map<String, dynamic>> voteInfo({
    required String voteId,
  }) async {
    try {
      final response = await _httpClient.get(
        DynamicsApiConstants.voteInfo,
        queryParameters: {
          'vote_id': voteId,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取投票信息失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 进行投票
  Future<void> doVote({
    required String voteId,
    required List<int> options,
  }) async {
    try {
      final response = await _httpClient.post(
        DynamicsApiConstants.doVote,
        queryParameters: {
          'csrf': '', // 需要从外部传入
        },
        data: {
          'vote_id': voteId,
          'options': options,
        },
      );

      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '投票失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 话题详情
  Future<Map<String, dynamic>?> topicTop({
    required String topicId,
  }) async {
    try {
      final response = await _httpClient.get(
        DynamicsApiConstants.topicTop,
        queryParameters: {
          'topic_id': topicId,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取话题详情失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 话题动态流
  Future<Map<String, dynamic>?> topicFeed({
    required String topicId,
    String? offset,
  }) async {
    try {
      final response = await _httpClient.get(
        DynamicsApiConstants.topicFeed,
        queryParameters: {
          'topic_id': topicId,
          'offset': offset,
          'timezone_offset': '-480',
          'features': 'itemOpusStyle,listOnlyfans',
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取话题动态失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 专栏列表
  Future<Map<String, dynamic>> articleList({
    required int mid,
    int? pn,
    int? ps,
  }) async {
    try {
      final response = await _httpClient.get(
        DynamicsApiConstants.articleList,
        queryParameters: {
          'mid': mid,
          'pn': pn ?? 1,
          'ps': ps ?? 10,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取专栏列表失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 点击预约
  Future<Map<String, dynamic>?> dynReserve({
    required String reserveId,
  }) async {
    try {
      final response = await _httpClient.post(
        DynamicsApiConstants.dynReserve,
        queryParameters: {
          'csrf': '', // 需要从外部传入
        },
        data: {
          'reserve_id': reserveId,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '预约失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 话题推荐
  Future<List<dynamic>?> dynTopicRcmd() async {
    try {
      final response = await _httpClient.get(
        DynamicsApiConstants.dynTopicRcmd,
      );

      if (response.data['code'] == 0) {
        return response.data['data']?['topics'] as List<dynamic>?;
      } else {
        throw ServerException(
          response.data['message'] ?? '获取话题推荐失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 图片详情
  Future<List<dynamic>?> dynPic({
    required String dynamicId,
  }) async {
    try {
      final response = await _httpClient.get(
        DynamicsApiConstants.dynPic,
        queryParameters: {
          'id': dynamicId,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data']?['pictures'] as List<dynamic>?;
      } else {
        throw ServerException(
          response.data['message'] ?? '获取图片详情失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// @提及搜索
  Future<Map<String, dynamic>?> dynMention({
    required String keyword,
  }) async {
    try {
      final response = await _httpClient.get(
        DynamicsApiConstants.dynMention,
        queryParameters: {
          'q': keyword,
          'type': 'user',
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '搜索失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 创建投票
  Future<int?> createVote({
    required String title,
    required List<String> options,
    int? choiceCnt,
  }) async {
    try {
      final response = await _httpClient.post(
        DynamicsApiConstants.createVote,
        queryParameters: {
          'csrf': '', // 需要从外部传入
        },
        data: {
          'title': title,
          'options': options,
          'choice_cnt': choiceCnt ?? 1,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data']?['vote_id'];
      } else {
        throw ServerException(
          response.data['message'] ?? '创建投票失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 更新投票
  Future<int?> updateVote({
    required String voteId,
    required String title,
    required List<String> options,
  }) async {
    try {
      final response = await _httpClient.post(
        DynamicsApiConstants.updateVote,
        queryParameters: {
          'csrf': '', // 需要从外部传入
        },
        data: {
          'vote_id': voteId,
          'title': title,
          'options': options,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data']?['vote_id'];
      } else {
        throw ServerException(
          response.data['message'] ?? '更新投票失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 创建预约
  Future<int?> createReserve({
    required String title,
    required int startTime,
    required int type,
  }) async {
    try {
      final response = await _httpClient.post(
        DynamicsApiConstants.createReserve,
        queryParameters: {
          'csrf': '', // 需要从外部传入
        },
        data: {
          'title': title,
          'start_time': startTime,
          'type': type,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data']?['reserve_id'];
      } else {
        throw ServerException(
          response.data['message'] ?? '创建预约失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 更新预约
  Future<int?> updateReserve({
    required String reserveId,
    required String title,
    required int startTime,
  }) async {
    try {
      final response = await _httpClient.post(
        DynamicsApiConstants.updateReserve,
        queryParameters: {
          'csrf': '', // 需要从外部传入
        },
        data: {
          'reserve_id': reserveId,
          'title': title,
          'start_time': startTime,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data']?['reserve_id'];
      } else {
        throw ServerException(
          response.data['message'] ?? '更新预约失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 预约信息
  Future<Map<String, dynamic>> reserveInfo({
    required String reserveId,
  }) async {
    try {
      final response = await _httpClient.get(
        DynamicsApiConstants.reserveInfo,
        queryParameters: {
          'reserve_id': reserveId,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取预约信息失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 关注的用户投票
  Future<List<dynamic>?> followeeVotes() async {
    try {
      final response = await _httpClient.get(
        DynamicsApiConstants.followeeVotes,
      );

      if (response.data['code'] == 0) {
        return response.data['data']?['items'] as List<dynamic>?;
      } else {
        throw ServerException(
          response.data['message'] ?? '获取投票列表失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 动态私密发布设置
  Future<void> dynPrivatePubSetting({
    required int status,
  }) async {
    try {
      final response = await _httpClient.post(
        DynamicsApiConstants.dynPrivatePubSetting,
        queryParameters: {
          'csrf': '', // 需要从外部传入
        },
        data: {
          'status': status,
        },
      );

      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '设置失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 编辑动态
  Future<Map<String, dynamic>?> editDyn({
    required String dynamicId,
    dynamic rawText,
    List? pics,
    int? publishTime,
    int? replyOption,
    int? privatePub,
  }) async {
    try {
      final response = await _httpClient.post(
        DynamicsApiConstants.editDyn,
        queryParameters: {
          'platform': 'web',
          'csrf': '', // 需要从外部传入
        },
        data: {
          "dyn_id_str": dynamicId,
          "content": {
            "contents": [
              if (rawText != null)
                {
                  "raw_text": rawText,
                  "type": 1,
                },
            ],
          },
          if (privatePub != null || replyOption != null || publishTime != null)
            "option": {
              'private_pub': privatePub,
              "timer_pub_time": publishTime,
              if (replyOption == 1) "close_comment": 1,
            },
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '编辑动态失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
