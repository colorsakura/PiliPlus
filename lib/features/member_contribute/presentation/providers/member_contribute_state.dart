import 'package:flutter/material.dart';
import 'package:PiliPlus/models/space/space/tab2.dart';

/// State for member contribute tabs
class MemberContributeState {
  const MemberContributeState({
    required this.items,
    this.tabs,
  });

  final List<SpaceTab2Item> items;
  final List<Tab>? tabs;

  MemberContributeState copyWith({
    List<SpaceTab2Item>? items,
    List<Tab>? tabs,
  }) {
    return MemberContributeState(
      items: items ?? this.items,
      tabs: tabs ?? this.tabs,
    );
  }
}
