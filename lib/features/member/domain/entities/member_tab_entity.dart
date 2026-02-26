import 'package:flutter/material.dart';
import 'package:PiliPlus/models/space/space/tab2.dart';

/// 成员空间标签页实体
///
/// 包含空间页面的标签页信息
class MemberTabEntity {
  /// 标签页标题
  final String? title;

  /// 标签页参数
  final String? param;

  /// 子标签页
  final List<MemberTabEntity>? items;

  const MemberTabEntity({
    this.title,
    this.param,
    this.items,
  });

  MemberTabEntity copyWith({
    String? title,
    String? param,
    List<MemberTabEntity>? items,
  }) {
    return MemberTabEntity(
      title: title ?? this.title,
      param: param ?? this.param,
      items: items ?? this.items,
    );
  }

  /// 从模型创建实体
  factory MemberTabEntity.fromModel(SpaceTab2 model) {
    return MemberTabEntity(
      title: model.title,
      param: model.param,
      items: model.items?.map((e) => MemberTabEntity._fromItem(e)).toList(),
    );
  }

  /// 从Item创建实体
  factory MemberTabEntity._fromItem(SpaceTab2Item item) {
    return MemberTabEntity(
      title: item.title,
      param: item.param,
      items: item.items?.map((e) => MemberTabEntity(
        title: e.title,
        param: e.param,
      )).toList(),
    );
  }

  /// 转换为Tab
  Tab toTab() => Tab(text: title ?? '');
}
