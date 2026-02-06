import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:PiliPlus/utils/storage.dart';

/// Metrics tracking for Rust API implementation during production rollout.
///
/// Tracks:
/// - Call counts (Rust vs Flutter)
/// - Latency metrics (p50, p95, p99)
/// - Fallback rates
/// - Error rates
///
/// Usage:
/// ```dart
/// // Record a successful Rust call
/// RustApiMetrics.recordRustCall(150); // 150ms latency
///
/// // Record a fallback to Flutter
/// RustApiMetrics.recordFallback('NetworkError');
///
/// // Get current stats
/// final stats = RustApiMetrics.getStats();
/// print('Fallback rate: ${stats['fallback_rate']}');
/// ```
class RustApiMetrics {
  RustApiMetrics._();

  // Counters
  static int _rustCallCount = 0;
  static int _rustFallbackCount = 0;
  static int _flutterCallCount = 0;
  static int _errorCount = 0;

  // Latency tracking (in milliseconds)
  static final List<int> _rustLatencies = [];
  static final List<int> _flutterLatencies = [];

  // Error tracking
  static final Map<String, int> _errorTypes = {};
  static final List<DateTime> _errorTimestamps = [];

  // Fallback reasons
  static final Map<String, int> _fallbackReasons = {};

  // Max samples to keep (prevent unbounded memory growth)
  static const int _maxLatencySamples = 10000;
  static const int _maxErrorSamples = 1000;

  /// Record a successful Rust API call.
  ///
  /// [latencyMs] should be the round-trip time in milliseconds.
  static void recordRustCall(int latencyMs) {
    _rustCallCount++;
    _rustLatencies.add(latencyMs);

    // Prevent unbounded growth
    if (_rustLatencies.length > _maxLatencySamples) {
      _rustLatencies.removeAt(0);
    }

    if (kDebugMode) {
      debugPrint('[RustMetrics] Rust call: ${latencyMs}ms (total: $_rustCallCount)');
    }
  }

  /// Record a fallback from Rust to Flutter implementation.
  ///
  /// [reason] should be a short description of why the fallback occurred.
  static void recordFallback(String reason) {
    _rustFallbackCount++;
    _fallbackReasons[reason] = (_fallbackReasons[reason] ?? 0) + 1;

    if (kDebugMode) {
      debugPrint('[RustMetrics] Fallback: $reason (total: $_rustFallbackCount)');
    }
  }

  /// Record a Flutter API call (when not using Rust).
  static void recordFlutterCall(int latencyMs) {
    _flutterCallCount++;
    _flutterLatencies.add(latencyMs);

    if (_flutterLatencies.length > _maxLatencySamples) {
      _flutterLatencies.removeAt(0);
    }

    if (kDebugMode) {
      debugPrint('[RustMetrics] Flutter call: ${latencyMs}ms (total: $_flutterCallCount)');
    }
  }

  /// Record an error.
  ///
  /// [errorType] should be a category of error (e.g., 'NetworkError', 'SerializationError').
  static void recordError(String errorType) {
    _errorCount++;
    _errorTypes[errorType] = (_errorTypes[errorType] ?? 0) + 1;
    _errorTimestamps.add(DateTime.now());

    if (_errorTimestamps.length > _maxErrorSamples) {
      _errorTimestamps.removeAt(0);
    }

    if (kDebugMode) {
      debugPrint('[RustMetrics] Error: $errorType (total: $_errorCount)');
    }
  }

  /// Get current metrics statistics.
  ///
  /// Returns a map containing:
  /// - `rust_calls`: Total Rust API calls
  /// - `rust_fallbacks`: Total fallbacks to Flutter
  /// - `flutter_calls`: Total Flutter API calls
  /// - `errors`: Total errors
  /// - `fallback_rate`: Fallbacks / Rust calls (0.0 to 1.0)
  /// - `rust_avg_latency`: Average Rust latency in ms
  /// - `rust_p50_latency`: 50th percentile Rust latency
  /// - `rust_p95_latency`: 95th percentile Rust latency
  /// - `rust_p99_latency`: 99th percentile Rust latency
  /// - `flutter_avg_latency`: Average Flutter latency in ms
  /// - `error_rate`: Errors / Total calls
  /// - `top_errors`: Map of error type to count (top 5)
  /// - `top_fallback_reasons`: Map of fallback reason to count (top 5)
  static Map<String, dynamic> getStats() {
    // Calculate percentiles
    final rustAvgLatency = _rustLatencies.isEmpty
        ? 0.0
        : _rustLatencies.reduce((a, b) => a + b) / _rustLatencies.length;

    final rustP50 = _rustLatencies.isEmpty
        ? 0.0
        : _percentile(_rustLatencies, 0.5);

    final rustP95 = _rustLatencies.isEmpty
        ? 0.0
        : _percentile(_rustLatencies, 0.95);

    final rustP99 = _rustLatencies.isEmpty
        ? 0.0
        : _percentile(_rustLatencies, 0.99);

    final flutterAvgLatency = _flutterLatencies.isEmpty
        ? 0.0
        : _flutterLatencies.reduce((a, b) => a + b) / _flutterLatencies.length;

    // Calculate rates
    final totalCalls = _rustCallCount + _flutterCallCount;
    final fallbackRate = _rustCallCount == 0
        ? 0.0
        : _rustFallbackCount / _rustCallCount;

    final errorRate = totalCalls == 0
        ? 0.0
        : _errorCount / totalCalls;

    // Get top errors (sorted by count)
    final topErrors = Map.fromEntries(
      _errorTypes.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
    );
    final top5Errors = topErrors.length > 5
        ? Map.fromEntries(topErrors.entries.take(5))
        : topErrors;

    // Get top fallback reasons (sorted by count)
    final topFallbacks = Map.fromEntries(
      _fallbackReasons.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
    );
    final top5Fallbacks = topFallbacks.length > 5
        ? Map.fromEntries(topFallbacks.entries.take(5))
        : topFallbacks;

    return {
      'rust_calls': _rustCallCount,
      'rust_fallbacks': _rustFallbackCount,
      'flutter_calls': _flutterCallCount,
      'errors': _errorCount,
      'fallback_rate': fallbackRate,
      'rust_avg_latency': rustAvgLatency,
      'rust_p50_latency': rustP50,
      'rust_p95_latency': rustP95,
      'rust_p99_latency': rustP99,
      'flutter_avg_latency': flutterAvgLatency,
      'error_rate': errorRate,
      'top_errors': top5Errors,
      'top_fallback_reasons': top5Fallbacks,
    };
  }

  /// Calculate percentile of a list of numbers.
  ///
  /// [percentile] should be between 0.0 and 1.0.
  static double _percentile(List<int> list, double percentile) {
    if (list.isEmpty) return 0.0;

    final sorted = List<int>.from(list)..sort();
    final index = (sorted.length * percentile).ceil() - 1;
    return sorted[index.clamp(0, sorted.length - 1)].toDouble();
  }

  /// Reset all metrics.
  ///
  /// Useful for starting a new measurement period (e.g., daily).
  static void reset() {
    _rustCallCount = 0;
    _rustFallbackCount = 0;
    _flutterCallCount = 0;
    _errorCount = 0;
    _rustLatencies.clear();
    _flutterLatencies.clear();
    _errorTypes.clear();
    _errorTimestamps.clear();
    _fallbackReasons.clear();

    if (kDebugMode) {
      debugPrint('[RustMetrics] Metrics reset');
    }
  }

  /// Get metrics as a formatted string for logging.
  static String getFormattedStats() {
    final stats = getStats();
    final buffer = StringBuffer();

    buffer.writeln('=== Rust API Metrics ===');
    buffer.writeln('Rust Calls: ${stats['rust_calls']}');
    buffer.writeln('Rust Fallbacks: ${stats['rust_fallbacks']}');
    buffer.writeln('Flutter Calls: ${stats['flutter_calls']}');
    buffer.writeln('Errors: ${stats['errors']}');
    buffer.writeln();
    buffer.writeln('Fallback Rate: ${(stats['fallback_rate'] * 100).toStringAsFixed(2)}%');
    buffer.writeln('Error Rate: ${(stats['error_rate'] * 100).toStringAsFixed(2)}%');
    buffer.writeln();
    buffer.writeln('Rust Latency:');
    buffer.writeln('  Avg: ${stats['rust_avg_latency'].toStringAsFixed(2)}ms');
    buffer.writeln('  P50: ${stats['rust_p50_latency'].toStringAsFixed(2)}ms');
    buffer.writeln('  P95: ${stats['rust_p95_latency'].toStringAsFixed(2)}ms');
    buffer.writeln('  P99: ${stats['rust_p99_latency'].toStringAsFixed(2)}ms');
    buffer.writeln();
    buffer.writeln('Flutter Latency:');
    buffer.writeln('  Avg: ${stats['flutter_avg_latency'].toStringAsFixed(2)}ms');
    buffer.writeln();
    buffer.writeln('Top Errors:');
    (stats['top_errors'] as Map).forEach((error, count) {
      buffer.writeln('  $error: $count');
    });
    buffer.writeln();
    buffer.writeln('Top Fallback Reasons:');
    (stats['top_fallback_reasons'] as Map).forEach((reason, count) {
      buffer.writeln('  $reason: $count');
    });

    return buffer.toString();
  }

  /// Persist metrics to local storage for analysis.
  static Future<void> persist() async {
    final stats = getStats();
    await GStorage.localCache.put('rust_api_metrics_${DateTime.now().millisecondsSinceEpoch}', stats);
    if (kDebugMode) {
      debugPrint('[RustMetrics] Metrics persisted');
    }
  }

  /// Load historical metrics from local storage.
  ///
  /// Returns a list of metric snapshots.
  static Future<List<Map<String, dynamic>>> loadHistorical() async {
    final box = GStorage.localCache;
    final keys = box.keys.where((key) => key.toString().startsWith('rust_api_metrics_')).toList();

    final snapshots = <Map<String, dynamic>>[];
    for (final key in keys) {
      final data = box.get(key);
      if (data is Map) {
        snapshots.add(Map<String, dynamic>.from(data));
      }
    }

    // Sort by timestamp (extract from key)
    snapshots.sort((a, b) {
      final aTime = int.parse(a['timestamp']?.toString() ?? '0');
      final bTime = int.parse(b['timestamp']?.toString() ?? '0');
      return bTime.compareTo(aTime); // Newest first
    });

    return snapshots;
  }

  /// Calculate health status based on current metrics.
  ///
  /// Returns 'HEALTHY', 'WARNING', or 'CRITICAL'.
  static String calculateHealthStatus() {
    final stats = getStats();
    final fallbackRate = stats['fallback_rate'] as double;
    final errorRate = stats['error_rate'] as double;
    final avgLatency = stats['rust_avg_latency'] as double;

    // Critical thresholds
    if (fallbackRate > 0.05) return 'CRITICAL'; // 5% fallback
    if (errorRate > 0.02) return 'CRITICAL';    // 2% errors
    if (avgLatency > 500) return 'CRITICAL';    // > 500ms avg

    // Warning thresholds
    if (fallbackRate > 0.02) return 'WARNING'; // 2% fallback
    if (errorRate > 0.01) return 'WARNING';    // 1% errors
    if (avgLatency > 200) return 'WARNING';    // > 200ms avg

    return 'HEALTHY';
  }

  /// Start periodic metrics persistence.
  ///
  /// Persists metrics every [interval] (default: 1 hour).
  static Timer startPeriodicPersistence([Duration interval = const Duration(hours: 1)]) {
    return Timer.periodic(interval, (_) {
      persist();
      if (kDebugMode) {
        debugPrint('[RustMetrics] Periodic persistence: ${getFormattedStats()}');
      }
    });
  }
}

/// Helper class for measuring latency of a block of code.
///
/// Usage:
/// ```dart
/// final stopwatch = RustMetricsStopwatch('rust_call');
/// await someOperation();
/// stopwatch.stop();
/// ```
class RustMetricsStopwatch {
  final String _type;
  final Stopwatch _stopwatch = Stopwatch();

  RustMetricsStopwatch(this._type) {
    _stopwatch.start();
  }

  /// Stop the stopwatch and record the latency.
  ///
  /// Automatically records to the appropriate metric based on type:
  /// - 'rust_call': Records as Rust call
  /// - 'flutter_call': Records as Flutter call
  void stop() {
    _stopwatch.stop();
    final latencyMs = _stopwatch.elapsedMilliseconds;

    switch (_type) {
      case 'rust_call':
        RustApiMetrics.recordRustCall(latencyMs);
        break;
      case 'flutter_call':
        RustApiMetrics.recordFlutterCall(latencyMs);
        break;
      default:
        if (kDebugMode) {
          debugPrint('[RustMetrics] Unknown stopwatch type: $_type');
        }
    }
  }

  /// Stop the stopwatch and record as a fallback.
  void stopAsFallback(String reason) {
    _stopwatch.stop();
    RustApiMetrics.recordFallback(reason);
  }

  /// Stop the stopwatch and record an error.
  void stopAsError(String errorType) {
    _stopwatch.stop();
    RustApiMetrics.recordError(errorType);
  }
}
