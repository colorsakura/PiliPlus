import 'dart:async';
import 'package:flutter/foundation.dart';

/// Debounce Controller V2 - Riverpod compatible
///
/// Handles debounced input changes for search/filter scenarios
class DebounceControllerV2 extends ChangeNotifier {
  DebounceControllerV2({
    Duration duration = const Duration(milliseconds: 300),
  }) : _duration = duration;

  final Duration _duration;
  Timer? _timer;
  String _currentValue = '';

  String get currentValue => _currentValue;
  bool get isPending => _timer != null;

  void onValueChanged(String value, ValueChanged<String> callback) {
    _currentValue = value;
    _timer?.cancel();
    _timer = Timer(_duration, () {
      callback(value);
      _timer = null;
    });
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    cancel();
    super.dispose();
  }
}
