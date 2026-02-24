import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:stream_transform/stream_transform.dart';

/// Mixin for debounced stream handling
///
/// Provides debounced stream processing for text input or other
/// rapidly changing values. Useful for search-as-you-type scenarios.
///
/// Type parameter S: The type of values in the stream (typically String for text input)
///
/// Example usage:
/// ```dart
/// class MySearchState extends State<MyWidget> with DebounceStreamState<String> {
///   @override
///   Duration get duration => const Duration(milliseconds: 300);
///
///   @override
///   void onValueChanged(String value) {
///     // Perform debounced search with value
///   }
/// }
/// ```
mixin DebounceStreamMixin<T> {
  /// Duration to debounce the stream
  /// Override to customize debounce duration
  Duration get duration => const Duration(milliseconds: 200);

  StreamController<T>? ctr;
  StreamSubscription<T>? _sub;

  /// Called when a new debounced value is available
  /// Override this to handle the debounced value
  void onValueChanged(T value);

  /// Initialize the stream subscription
  void subInit() {
    _sub = (ctr = StreamController<T>()).stream
        .debounce(duration, trailing: true)
        .listen(onValueChanged);
  }

  /// Dispose the stream subscription
  void subDispose() {
    _sub?.cancel();
    ctr?.close();
    _sub = null;
    ctr = null;
  }
}

/// State extension for debounced stream handling
///
/// Automatically manages the lifecycle of the debounce stream
/// by calling subInit() in initState() and subDispose() in dispose().
///
/// Type parameters:
/// - T: The StatefulWidget type
/// - S: The type of values in the stream
///
/// Example usage:
/// ```dart
/// class _MySearchState extends DebounceStreamState<MyWidget, String> {
///   @override
///   Duration get duration => const Duration(milliseconds: 300);
///
///   @override
///   void onValueChanged(String value) {
///     // Perform debounced search
///   }
/// }
/// ```
abstract class DebounceStreamState<T extends StatefulWidget, S> extends State<T>
    with DebounceStreamMixin<S> {
  @override
  void dispose() {
    subDispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    subInit();
  }
}
