import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';

class CustomScrollBehavior extends MaterialScrollBehavior {
  const CustomScrollBehavior(this.dragDevices);

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;

  @override
  final Set<PointerDeviceKind> dragDevices;
}

const Set<PointerDeviceKind> desktopDragDevices = <PointerDeviceKind>{
  PointerDeviceKind.touch,
  PointerDeviceKind.stylus,
  PointerDeviceKind.invertedStylus,
  PointerDeviceKind.trackpad,
  PointerDeviceKind.unknown,
  PointerDeviceKind.mouse,
};

const Set<PointerDeviceKind> mobileDragDevices = <PointerDeviceKind>{
  PointerDeviceKind.touch,
  PointerDeviceKind.stylus,
  PointerDeviceKind.invertedStylus,
};
