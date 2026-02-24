import 'package:PiliPlus/features/home/presentation/pages/home_page.dart';
import 'package:PiliPlus/models/common/enum_with_label.dart';
import 'package:PiliPlus/features/dynamics/dynamics.dart';
import 'package:PiliPlus/features/mine/mine.dart';
import 'package:flutter/material.dart';

enum NavigationBarType implements EnumWithLabel {
  home(
    '首页',
    Icon(Icons.home_outlined, size: 23),
    Icon(Icons.home, size: 21),
    HomePage(),
  ),
  dynamics(
    '动态',
    Icon(Icons.motion_photos_on_outlined, size: 21),
    Icon(Icons.motion_photos_on, size: 21),
    DynamicsPage(),
  ),
  mine(
    '我的',
    Icon(Icons.person_outline, size: 21),
    Icon(Icons.person, size: 21),
    MinePage(),
  )
  ;

  @override
  final String label;
  final Icon icon;
  final Icon selectIcon;
  final Widget page;

  const NavigationBarType(this.label, this.icon, this.selectIcon, this.page);
}
