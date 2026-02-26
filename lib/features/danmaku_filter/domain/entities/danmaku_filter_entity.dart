import 'package:PiliPlus/models/user/danmaku_block.dart';

/// Danmaku filter entity
class DanmakuFilterEntity {
  final List<FilterRule> keywordRules;
  final List<FilterRule> regexRules;
  final List<FilterRule> userRules;

  const DanmakuFilterEntity({
    this.keywordRules = const [],
    this.regexRules = const [],
    this.userRules = const [],
  });

  /// Create from DanmakuBlockDataModel
  factory DanmakuFilterEntity.fromModel(DanmakuBlockDataModel model) {
    return DanmakuFilterEntity(
      keywordRules: model.rule
          .map((r) => FilterRule.fromSimpleRule(r, FilterRuleType.keyword))
          .toList(),
      regexRules: model.rule1
          .map((r) => FilterRule.fromSimpleRule(r, FilterRuleType.regex))
          .toList(),
      userRules: model.rule2
          .map((r) => FilterRule.fromSimpleRule(r, FilterRuleType.user))
          .toList(),
    );
  }

  /// Get all rules
  List<FilterRule> get allRules => [
        ...keywordRules,
        ...regexRules,
        ...userRules,
      ];

  /// Get total count
  int get totalCount => allRules.length;

  /// Get rules by type
  List<FilterRule> getRulesByType(FilterRuleType type) {
    switch (type) {
      case FilterRuleType.keyword:
        return keywordRules;
      case FilterRuleType.regex:
        return regexRules;
      case FilterRuleType.user:
        return userRules;
    }
  }
}

/// Filter rule entity
class FilterRule {
  final int id;
  final String filter;
  final FilterRuleType type;

  FilterRule({
    required this.id,
    required this.filter,
    required this.type,
  });

  /// Create from SimpleRule
  factory FilterRule.fromSimpleRule(SimpleRule simpleRule, FilterRuleType type) {
    return FilterRule(
      id: simpleRule.id ?? 0,
      filter: simpleRule.filter,
      type: type,
    );
  }

  @override
  String toString() => 'FilterRule(id: $id, type: $type, filter: $filter)';
}

/// Filter rule type enum
enum FilterRuleType {
  keyword(0),
  regex(1),
  user(2);

  final int value;
  const FilterRuleType(this.value);

  static FilterRuleType fromValue(int value) {
    return FilterRuleType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => FilterRuleType.keyword,
    );
  }
}
