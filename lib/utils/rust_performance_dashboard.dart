import 'dart:async';
import 'package:flutter/material.dart';
import 'package:PiliPlus/utils/rust_api_metrics.dart';

/// Performance dashboard widget for displaying Rust API metrics.
///
/// This widget provides a visual dashboard for monitoring the performance
/// and health of Rust API implementations. It displays real-time metrics
/// including call counts, latency percentiles, error rates, and fallback rates.
///
/// **Features:**
/// - Real-time metrics display
/// - Health status indicator (HEALTHY/WARNING/CRITICAL)
/// - Per-API breakdown (if using enhanced metrics)
/// - Latency charts (p50, p95, p99)
/// - Error and fallback tracking
/// - Reset metrics functionality
///
/// **Usage:**
/// ```dart
/// // Show as a full-screen page
/// Navigator.push(context, MaterialPageRoute(
///   builder: (context) => const RustPerformanceDashboard(),
/// ));
///
/// // Or embed in a settings page
/// const Card(child: RustPerformanceDashboard compact: true)
/// ```
class RustPerformanceDashboard extends StatefulWidget {
  /// Whether to show a compact version of the dashboard.
  ///
  /// When `true`, shows only the most critical metrics in a smaller layout.
  /// Suitable for embedding in settings pages or sidebars.
  final bool compact;

  /// Whether to enable auto-refresh of metrics.
  ///
  /// When `true`, metrics automatically refresh every second.
  /// Default is `true`.
  final bool autoRefresh;

  const RustPerformanceDashboard({
    super.key,
    this.compact = false,
    this.autoRefresh = true,
  });

  @override
  State<RustPerformanceDashboard> createState() => _RustPerformanceDashboardState();
}

class _RustPerformanceDashboardState extends State<RustPerformanceDashboard> {
  Map<String, dynamic> _stats = {};
  String _healthStatus = 'UNKNOWN';
  bool _loading = true;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
    if (widget.autoRefresh) {
      // Auto-refresh every second
      _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          _loadMetrics();
        }
      });
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMetrics() async {
    if (!mounted) return;

    try {
      final stats = RustApiMetrics.getStats();
      final health = RustApiMetrics.calculateHealthStatus();

      if (mounted) {
        setState(() {
          _stats = stats;
          _healthStatus = health;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _resetMetrics() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Metrics'),
        content: const Text('Are you sure you want to reset all metrics? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      RustApiMetrics.reset();
      _loadMetrics();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Metrics reset successfully')),
        );
      }
    }
  }

  Future<void> _persistMetrics() async {
    try {
      await RustApiMetrics.persist();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Metrics persisted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to persist metrics: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return _buildCompactDashboard();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rust API Performance Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMetrics,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _persistMetrics,
            tooltip: 'Persist Metrics',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _resetMetrics,
            tooltip: 'Reset Metrics',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMetrics,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _HealthIndicator(healthStatus: _healthStatus),
                  const SizedBox(height: 16),
                  _CallCountsCard(stats: _stats),
                  const SizedBox(height: 16),
                  _LatencyCard(stats: _stats),
                  const SizedBox(height: 16),
                  _ErrorRateCard(stats: _stats),
                  const SizedBox(height: 16),
                  _FallbackRateCard(stats: _stats),
                  const SizedBox(height: 16),
                  _TopErrorsCard(stats: _stats),
                  const SizedBox(height: 16),
                  _TopFallbacksCard(stats: _stats),
                ],
              ),
            ),
    );
  }

  Widget _buildCompactDashboard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Rust API Performance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _HealthIndicator(healthStatus: _healthStatus),
              ],
            ),
            const Divider(height: 24),
            _MetricRow(
              label: 'Calls',
              value: _stats['rust_calls']?.toString() ?? '0',
              icon: Icons.call_made,
            ),
            _MetricRow(
              label: 'Fallbacks',
              value: _stats['rust_fallbacks']?.toString() ?? '0',
              icon: Icons.sync_problem,
            ),
            _MetricRow(
              label: 'Avg Latency',
              value: '${(_stats['rust_avg_latency'] as double?)?.toStringAsFixed(1) ?? '0.0'}ms',
              icon: Icons.speed,
            ),
            _MetricRow(
              label: 'Error Rate',
              value: '${((_stats['error_rate'] as double?)?.toStringAsFixed(2) ?? '0.00')}',
              icon: Icons.error_outline,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget that displays a single metric row in the compact dashboard.
class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Health status indicator widget.
class _HealthIndicator extends StatelessWidget {
  final String healthStatus;

  const _HealthIndicator({required this.healthStatus});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (healthStatus) {
      case 'HEALTHY':
        color = Colors.green;
        icon = Icons.check_circle;
        label = 'Healthy';
        break;
      case 'WARNING':
        color = Colors.orange;
        icon = Icons.warning;
        label = 'Warning';
        break;
      case 'CRITICAL':
        color = Colors.red;
        icon = Icons.error;
        label = 'Critical';
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
        label = 'Unknown';
    }

    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const Spacer(),
            Text(
              'Status: $healthStatus',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card displaying call count metrics.
class _CallCountsCard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _CallCountsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final rustCalls = stats['rust_calls'] as int? ?? 0;
    final fallbacks = stats['rust_fallbacks'] as int? ?? 0;
    final flutterCalls = stats['flutter_calls'] as int? ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Call Counts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _MetricTile(
              label: 'Rust Calls',
              value: rustCalls.toString(),
              icon: Icons.rocket_launch,
              color: Colors.green,
            ),
            _MetricTile(
              label: 'Fallbacks to Flutter',
              value: fallbacks.toString(),
              icon: Icons.sync_alt,
              color: Colors.orange,
            ),
            _MetricTile(
              label: 'Flutter Calls (Direct)',
              value: flutterCalls.toString(),
              icon: Icons.flutter_dash,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

/// Card displaying latency metrics.
class _LatencyCard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _LatencyCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final avg = (stats['rust_avg_latency'] as double?)?.toStringAsFixed(2) ?? '0.00';
    final p50 = (stats['rust_p50_latency'] as double?)?.toStringAsFixed(2) ?? '0.00';
    final p95 = (stats['rust_p95_latency'] as double?)?.toStringAsFixed(2) ?? '0.00';
    final p99 = (stats['rust_p99_latency'] as double?)?.toStringAsFixed(2) ?? '0.00';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rust Latency (ms)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _MetricTile(
              label: 'Average',
              value: '${avg}ms',
              icon: Icons.speed,
              color: Colors.blue,
            ),
            _MetricTile(
              label: 'P50 (Median)',
              value: '${p50}ms',
              icon: Icons.timeline,
              color: Colors.green,
            ),
            _MetricTile(
              label: 'P95 (95th percentile)',
              value: '${p95}ms',
              icon: Icons.show_chart,
              color: Colors.orange,
            ),
            _MetricTile(
              label: 'P99 (99th percentile)',
              value: '${p99}ms',
              icon: Icons.trending_up,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

/// Card displaying error rate metrics.
class _ErrorRateCard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _ErrorRateCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final errorRate = stats['error_rate'] as double? ?? 0.0;
    final errorCount = stats['errors'] as int? ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Error Rate',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _MetricTile(
              label: 'Error Rate',
              value: '${(errorRate * 100).toStringAsFixed(2)}%',
              icon: Icons.error_outline,
              color: errorRate > 0.01 ? Colors.red : Colors.green,
            ),
            _MetricTile(
              label: 'Total Errors',
              value: errorCount.toString(),
              icon: Icons.bug_report,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}

/// Card displaying fallback rate metrics.
class _FallbackRateCard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _FallbackRateCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final fallbackRate = stats['fallback_rate'] as double? ?? 0.0;
    final fallbackCount = stats['rust_fallbacks'] as int? ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fallback Rate',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _MetricTile(
              label: 'Fallback Rate',
              value: '${(fallbackRate * 100).toStringAsFixed(2)}%',
              icon: Icons.sync_problem,
              color: fallbackRate > 0.02 ? Colors.orange : Colors.green,
            ),
            _MetricTile(
              label: 'Total Fallbacks',
              value: fallbackCount.toString(),
              icon: Icons.sync_alt,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

/// Card displaying top errors.
class _TopErrorsCard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _TopErrorsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final topErrors = stats['top_errors'] as Map? ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Errors',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            if (topErrors.isEmpty)
              const Text('No errors recorded')
            else
              ...topErrors.entries.map((entry) => _MetricTile(
                    label: entry.key.toString(),
                    value: entry.value.toString(),
                    icon: Icons.error,
                    color: Colors.red,
                  )),
          ],
        ),
      ),
    );
  }
}

/// Card displaying top fallback reasons.
class _TopFallbacksCard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _TopFallbacksCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final topFallbacks = stats['top_fallback_reasons'] as Map? ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Fallback Reasons',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            if (topFallbacks.isEmpty)
              const Text('No fallbacks recorded')
            else
              ...topFallbacks.entries.map((entry) => _MetricTile(
                    label: entry.key.toString(),
                    value: entry.value.toString(),
                    icon: Icons.sync_problem,
                    color: Colors.orange,
                  )),
          ],
        ),
      ),
    );
  }
}

/// Widget displaying a single metric tile.
class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
