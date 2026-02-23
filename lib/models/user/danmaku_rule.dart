import 'package:PiliPlus/grpc/bilibili/community/service/dm/v1.pb.dart';
import 'package:PiliPlus/models/user/danmaku_block.dart';

class RuleFilter {
  static final _regExp = RegExp(r'^/(.*)/$');

  List<String> dmFilterString = [];
  List<RegExp> dmRegExp = [];
  Set<String> dmUid = {};

  int count = 0;

  RuleFilter(this.dmFilterString, this.dmRegExp, this.dmUid, [int? count]) {
    this.count =
        count ?? dmFilterString.length + dmRegExp.length + dmUid.length;
  }

  RuleFilter.fromRuleTypeEntries(List<List<SimpleRule>> rules) {
    dmFilterString = rules[0].map((e) => e.filter).toList();

    dmRegExp = rules[1]
        .map(
          (e) => RegExp(
            _regExp.matchAsPrefix(e.filter)?.group(1) ?? e.filter,
            caseSensitive: false,
          ),
        )
        .toList();

    dmUid = rules[2].map((e) => e.filter).toSet();

    count = dmFilterString.length + dmRegExp.length + dmUid.length;
  }

  RuleFilter.empty();

  /// 从 JSON 创建
  factory RuleFilter.fromJson(Map<String, dynamic> json) {
    final filter = RuleFilter.empty();

    filter.dmFilterString =
        (json['dmFilterString'] as List?)?.cast<String>() ?? [];
    filter.dmUid = (json['dmUid'] as List?)?.cast<String>().toSet() ?? {};

    // 解析正则表达式
    final regExpList = (json['dmRegExp'] as List?)?.cast<String>();
    if (regExpList != null) {
      filter.dmRegExp = regExpList
          .map(
            (pattern) => RegExp(
              _regExp.matchAsPrefix(pattern)?.group(1) ?? pattern,
              caseSensitive: false,
            ),
          )
          .toList();
    }

    filter.count =
        json['count'] ??
        filter.dmFilterString.length +
            filter.dmRegExp.length +
            filter.dmUid.length;

    return filter;
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() => {
    'dmFilterString': dmFilterString,
    'dmRegExp': dmRegExp.map((r) => r.pattern).toList(),
    'dmUid': dmUid.toList(),
    'count': count,
  };

  bool remove(DanmakuElem elem) {
    return dmUid.contains(elem.midHash) ||
        dmFilterString.any((i) => elem.content.contains(i)) ||
        dmRegExp.any((i) => i.hasMatch(elem.content));
  }
}
