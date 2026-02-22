import 'package:PiliPlus/features/home/domain/entities/search_suggestion.dart';
import 'package:PiliPlus/http/api.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/utils/wbi_sign.dart';

/// 搜索建议远程数据源
class SearchRemoteDataSource {
  /// 获取默认搜索建议
  Future<SearchSuggestion?> getDefaultSearchSuggestion() async {
    try {
      final res = await Request().get(
        Api.searchDefault,
        queryParameters: await WbiSign.makSign({'web_location': 333.1365}),
      );
      if (res.data['code'] == 0) {
        final data = res.data['data'];
        if (data != null) {
          return SearchSuggestion.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
