import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/http/api.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/model_rec_video_item.dart';
import 'package:PiliPlus/utils/global_data.dart';
import 'package:PiliPlus/utils/recommend_filter.dart';
import 'package:PiliPlus/utils/login_utils.dart';
import 'package:dio/dio.dart';

/// App端推荐API
///
/// 使用Bilibili APP端接口获取推荐内容
/// URL: https://app.bilibili.com/x/v2/feed/index
class RcmdAppApi {
  /// 获取APP端推荐列表
  ///
  /// 参数:
  /// - [ps]: 页面大小（推荐数量）
  /// - [freshIdx]: 刷新索引（idx参数）
  static Future<LoadingState<List<RecVideoItemModel>>> getRecommendList({
    required int ps,
    required int freshIdx,
  }) async {
    try {
      // 构建APP端请求参数
      final params = {
        'c_locale': 'zh_CN',
        'channel': 'master',
        'column': 4,
        'device': 'pad',
        'device_name': 'android',
        'device_type': 0,
        'disable_rcmd': 0,
        'flush': 5,
        'fnval': 976,
        'fnver': 0,
        'force_host': 2, // 使用https
        'fourk': 1,
        'guidance': 0,
        'https_url_req': 0,
        'idx': freshIdx,
        'mobi_app': 'android_hd',
        'network': 'wifi',
        'platform': 'android',
        'player_net': 1,
        'pull': freshIdx == 0 ? 'true' : 'false',
        'qn': 32,
        'recsys_mode': 0,
        's_locale': 'zh_CN',
        'splash_id': '',
        'statistics': Constants.statistics,
        'voice_balance': 0,
        'ps': ps,
      };

      final response = await Request().get(
        Api.recommendListApp,
        queryParameters: params,
        options: Options(
          headers: {
            'buvid': LoginUtils.generateBuvid(),
            'fp_local':
                '1111111111111111111111111111111111111111111111111111111111111111',
            'fp_remote':
                '1111111111111111111111111111111111111111111111111111111111111111',
            'session_id': '11111111',
            'env': 'prod',
            'app-key': 'android_hd',
            'User-Agent': Constants.userAgent,
            'x-bili-trace-id': Constants.traceId,
            'x-bili-aurora-eid': '',
            'x-bili-aurora-zone': '',
            'bili-http-engine': 'cronet',
          },
        ),
      );

      if (response.data['code'] == 0) {
        List<RecVideoItemModel> list = [];
        for (final i in response.data['data']['items']) {
          // 屏蔽推广和拉黑用户
          if (i['card_goto'] != 'ad_av' &&
              i['card_goto'] != 'ad_web_s' &&
              i['ad_info'] == null &&
              (i['args'] != null &&
                  !GlobalData().blackMids.contains(i['args']['up_id']))) {
            RecVideoItemModel videoItem = RecVideoItemModel.fromJson(i);
            // 应用推荐过滤
            if (!RecommendFilter.filter(videoItem)) {
              list.add(videoItem);
            }
          }
        }
        return Success(list);
      } else {
        return Error(
          response.data['message'] ?? 'Unknown error',
          code: response.data['code'],
        );
      }
    } catch (e) {
      return Error(e.toString());
    }
  }
}
