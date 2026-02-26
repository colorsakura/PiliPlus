import 'package:flutter/material.dart';

/// Simple Tab Controller V2 - Riverpod compatible
///
/// A lightweight wrapper around TabController for use with Riverpod
class SimpleTabControllerV2 extends ChangeNotifier {
  SimpleTabControllerV2({
    required int length,
    TickerProvider? vsync,
    int initialIndex = 0,
  })  : assert(length > 0),
        assert(initialIndex >= 0 && initialIndex < length),
        _length = length {
    if (vsync != null) {
      _tabController = TabController(
        vsync: vsync,
        length: length,
        initialIndex: initialIndex,
      );
      _tabController!.addListener(_onTabChanged);
    }
  }

  final int _length;
  TabController? _tabController;
  int _currentIndex = 0;

  TabController? get tabController => _tabController;
  int get currentIndex => _currentIndex;
  int get length => _length;
  bool get hasController => _tabController != null;

  void _onTabChanged() {
    if (_tabController != null && _tabController!.index != _currentIndex) {
      _currentIndex = _tabController!.index;
      notifyListeners();
    }
  }

  void animateTo(int index) {
    assert(index >= 0 && index < _length);
    _tabController?.animateTo(index);
  }

  void setIndex(int index) {
    assert(index >= 0 && index < _length);
    _currentIndex = index;
    _tabController?.index = index;
    notifyListeners();
  }

  @override
  void dispose() {
    _tabController?.removeListener(_onTabChanged);
    _tabController?.dispose();
    super.dispose();
  }
}
