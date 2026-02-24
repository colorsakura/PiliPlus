import 'dart:convert';

import 'package:archive/archive.dart' show getCrc32;
import 'package:flutter/material.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/user/danmaku_block.dart';
import 'package:PiliPlus/features/danmaku_block/domain/usecases/get_danmaku_filter_rules_usecase.dart';
import 'package:PiliPlus/features/danmaku_block/domain/usecases/delete_danmaku_rule_usecase.dart';
import 'package:PiliPlus/features/danmaku_block/domain/usecases/add_danmaku_rule_usecase.dart';

/// State for danmaku block rules
class DanmakuBlockState {
  const DanmakuBlockState({
    required this.rules,
    this.isLoading = false,
    this.toastMessage,
  });

  final List<List<SimpleRule>> rules;
  final bool isLoading;
  final String? toastMessage;

  DanmakuBlockState copyWith({
    List<List<SimpleRule>>? rules,
    bool? isLoading,
    String? toastMessage,
  }) {
    return DanmakuBlockState(
      rules: rules ?? this.rules,
      isLoading: isLoading ?? this.isLoading,
      toastMessage: toastMessage,
    );
  }
}

/// Controller for danmaku block rules
class DanmakuBlockController extends ChangeNotifier {
  DanmakuBlockController({
    required GetDanmakuFilterRulesUseCase getDanmakuFilterRulesUseCase,
    required DeleteDanmakuRuleUseCase deleteDanmakuRuleUseCase,
    required AddDanmakuRuleUseCase addDanmakuRuleUseCase,
  })  : _getDanmakuFilterRulesUseCase = getDanmakuFilterRulesUseCase,
        _deleteDanmakuRuleUseCase = deleteDanmakuRuleUseCase,
        _addDanmakuRuleUseCase = addDanmakuRuleUseCase,
        _state = const DanmakuBlockState(rules: [[], [], []]);

  final GetDanmakuFilterRulesUseCase _getDanmakuFilterRulesUseCase;
  final DeleteDanmakuRuleUseCase _deleteDanmakuRuleUseCase;
  final AddDanmakuRuleUseCase _addDanmakuRuleUseCase;

  DanmakuBlockState _state;
  late TabController tabController;

  DanmakuBlockState get state => _state;

  /// Initialize tab controller (must be called after TickerProvider is available)
  void initTabController(TickerProvider vsync) {
    tabController = TabController(length: 3, vsync: vsync);
    // Start loading after tab controller is initialized
    queryDanmakuFilter();
  }

  /// Fetch all danmaku block rules
  Future<void> queryDanmakuFilter() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final result = await _getDanmakuFilterRulesUseCase();

    if (result case Success(:final response)) {
      _state = DanmakuBlockState(
        rules: [response.rule, response.rule1, response.rule2],
        isLoading: false,
        toastMessage: response.toast,
      );
    } else {
      _state = _state.copyWith(isLoading: false);
    }

    notifyListeners();
  }

  /// Delete a danmaku block rule
  Future<void> deleteRule(int tabIndex, int itemIndex, int id) async {
    final result = await _deleteDanmakuRuleUseCase(id);

    if (result.isSuccess) {
      final newRules = List<List<SimpleRule>>.from(_state.rules);
      newRules[tabIndex] = List<SimpleRule>.from(newRules[tabIndex])..removeAt(itemIndex);
      _state = _state.copyWith(rules: newRules);
      notifyListeners();
    }
  }

  /// Add a new danmaku block rule
  Future<void> addRule({
    required String filter,
    required int type,
  }) async {
    String processedFilter = filter;
    if (type == 2) {
      processedFilter = getCrc32(ascii.encode(filter), 0).toRadixString(16);
    }

    final result = await _addDanmakuRuleUseCase(
      filter: processedFilter,
      type: type,
    );

    if (result case Success(:final response)) {
      final newRules = List<List<SimpleRule>>.from(_state.rules);
      newRules[type] = List<SimpleRule>.from(newRules[type])..add(response);
      _state = _state.copyWith(rules: newRules);
      notifyListeners();
    }
  }

  /// Get rules for a specific tab
  List<SimpleRule> getRulesForTab(int index) {
    if (index >= 0 && index < _state.rules.length) {
      return _state.rules[index];
    }
    return [];
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }
}
