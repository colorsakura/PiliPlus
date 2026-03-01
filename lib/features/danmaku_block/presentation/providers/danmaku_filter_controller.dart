import 'dart:convert';

import 'package:archive/archive.dart' show getCrc32;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/models/user/danmaku_block.dart';
import 'package:PiliPlus/features/danmaku_block/domain/usecases/get_danmaku_filter_rules_usecase.dart';
import 'package:PiliPlus/features/danmaku_block/domain/usecases/delete_danmaku_rule_usecase.dart';
import 'package:PiliPlus/features/danmaku_block/domain/usecases/add_danmaku_rule_usecase.dart';
import 'package:PiliPlus/features/danmaku_block/presentation/providers/danmaku_block_providers.dart';
import 'package:PiliPlus/http/loading_state.dart';

part 'danmaku_filter_controller.g.dart';

/// State for danmaku block rules
class DanmakuFilterState {
  const DanmakuFilterState({
    required this.rules,
    this.isLoading = false,
    this.toastMessage,
  });

  final List<List<SimpleRule>> rules;
  final bool isLoading;
  final String? toastMessage;

  DanmakuFilterState copyWith({
    List<List<SimpleRule>>? rules,
    bool? isLoading,
    String? toastMessage,
  }) {
    return DanmakuFilterState(
      rules: rules ?? this.rules,
      isLoading: isLoading ?? this.isLoading,
      toastMessage: toastMessage,
    );
  }
}

/// Controller for danmaku block rules (Riverpod version)
@riverpod
class DanmakuFilterController extends _$DanmakuFilterController {
  @override
  DanmakuFilterState build() {
    // Fetch data on initialization
    queryDanmakuFilter();
    return const DanmakuFilterState(rules: [[], [], []]);
  }

  /// Fetch all danmaku block rules
  Future<void> queryDanmakuFilter() async {
    state = state.copyWith(isLoading: true);

    try {
      final getRules = ref.read(getDanmakuFilterRulesUseCaseProvider);
      final result = await getRules();

      if (result case Success(:final response)) {
        state = DanmakuFilterState(
          rules: [response.rule, response.rule1, response.rule2],
          isLoading: false,
          toastMessage: response.toast,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Delete a danmaku block rule
  Future<void> deleteRule(int tabIndex, int itemIndex, int id) async {
    final deleteRule = ref.read(deleteDanmakuRuleUseCaseProvider);
    final result = await deleteRule(id);

    if (result.isSuccess) {
      final newRules = List<List<SimpleRule>>.from(state.rules);
      newRules[tabIndex] = List<SimpleRule>.from(newRules[tabIndex])
        ..removeAt(itemIndex);
      state = state.copyWith(rules: newRules);
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

    final addRule = ref.read(addDanmakuRuleUseCaseProvider);
    final result = await addRule(
      filter: processedFilter,
      type: type,
    );

    if (result case Success(:final response)) {
      final newRules = List<List<SimpleRule>>.from(state.rules);
      newRules[type] = List<SimpleRule>.from(newRules[type])..add(response);
      state = state.copyWith(rules: newRules);
    }
  }

  /// Get rules for a specific tab
  List<SimpleRule> getRulesForTab(int index) {
    if (index >= 0 && index < state.rules.length) {
      return state.rules[index];
    }
    return [];
  }
}
