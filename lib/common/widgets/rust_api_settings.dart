import 'package:PiliPlus/utils/rust_api_metrics.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

/// Development settings for Rust API integration.
///
/// This widget provides UI controls for:
/// - Toggling Rust video API on/off
/// - Enabling validation mode
/// - Viewing current metrics
/// - Resetting metrics
///
/// **Usage:**
/// ```dart
/// // In development settings page
/// if (kDebugMode) {
///   RustApiSettingsWidget();
/// }
/// ```
class RustApiSettingsWidget extends StatefulWidget {
  const RustApiSettingsWidget({super.key});

  @override
  State<RustApiSettingsWidget> createState() => _RustApiSettingsWidgetState();
}

class _RustApiSettingsWidgetState extends State<RustApiSettingsWidget> {
  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Divider(),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Rust API Integration (Development)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Use Rust Video API'),
          subtitle: const Text('Enable Rust implementation for video API calls'),
          value: GStorage.setting
              .get(SettingBoxKey.useRustVideoApi, defaultValue: false),
          onChanged: (value) {
            setState(() {
              GStorage.setting.put(SettingBoxKey.useRustVideoApi, value);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(value ? 'Rust API enabled' : 'Rust API disabled'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
        SwitchListTile(
          title: const Text('Enable Validation'),
          subtitle: const Text(
            'Run A/B validation comparing Rust and Flutter implementations',
          ),
          value: GStorage.setting
              .get(SettingBoxKey.enableValidation, defaultValue: false),
          onChanged: (value) {
            setState(() {
              GStorage.setting.put(SettingBoxKey.enableValidation, value);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  value ? 'Validation enabled' : 'Validation disabled',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
        ListTile(
          title: const Text('View Metrics'),
          subtitle: const Text('See current Rust API performance metrics'),
          leading: const Icon(Icons.analytics),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const RustApiMetricsDialog(),
            );
          },
        ),
        ListTile(
          title: const Text('Reset Metrics'),
          subtitle: const Text('Clear all collected metrics data'),
          leading: const Icon(Icons.refresh),
          onTap: () {
            RustApiMetrics.reset();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Metrics reset'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Dialog displaying current Rust API metrics.
class RustApiMetricsDialog extends StatefulWidget {
  const RustApiMetricsDialog({super.key});

  @override
  State<RustApiMetricsDialog> createState() => _RustApiMetricsDialogState();
}

class _RustApiMetricsDialogState extends State<RustApiMetricsDialog> {
  @override
  Widget build(BuildContext context) {
    final stats = RustApiMetrics.getStats();
    final healthStatus = RustApiMetrics.calculateHealthStatus();

    return AlertDialog(
      title: const Text('Rust API Metrics'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Health status indicator
            _buildHealthIndicator(healthStatus),
            const SizedBox(height: 16),

            // Call counts
            _buildMetricCard('Calls', [
              _buildMetricRow('Rust Calls', stats['rust_calls'].toString()),
              _buildMetricRow('Rust Fallbacks', stats['rust_fallbacks'].toString()),
              _buildMetricRow('Flutter Calls', stats['flutter_calls'].toString()),
              _buildMetricRow('Errors', stats['errors'].toString()),
            ]),
            const SizedBox(height: 12),

            // Rates
            _buildMetricCard('Rates', [
              _buildMetricRow(
                'Fallback Rate',
                '${((stats['fallback_rate'] as double) * 100).toStringAsFixed(2)}%',
              ),
              _buildMetricRow(
                'Error Rate',
                '${((stats['error_rate'] as double) * 100).toStringAsFixed(2)}%',
              ),
            ]),
            const SizedBox(height: 12),

            // Rust latency
            _buildMetricCard('Rust Latency (ms)', [
              _buildMetricRow(
                'Average',
                stats['rust_avg_latency'].toStringAsFixed(2),
              ),
              _buildMetricRow(
                'P50',
                stats['rust_p50_latency'].toStringAsFixed(2),
              ),
              _buildMetricRow(
                'P95',
                stats['rust_p95_latency'].toStringAsFixed(2),
              ),
              _buildMetricRow(
                'P99',
                stats['rust_p99_latency'].toStringAsFixed(2),
              ),
            ]),
            const SizedBox(height: 12),

            // Flutter latency
            _buildMetricCard('Flutter Latency (ms)', [
              _buildMetricRow(
                'Average',
                stats['flutter_avg_latency'].toStringAsFixed(2),
              ),
            ]),
            const SizedBox(height: 12),

            // Top errors
            if ((stats['top_errors'] as Map).isNotEmpty)
              _buildMetricCard('Top Errors', [
                ...(stats['top_errors'] as Map).entries.map((entry) =>
                    _buildMetricRow(entry.key.toString(), entry.value.toString())),
              ]),
            const SizedBox(height: 12),

            // Top fallback reasons
            if ((stats['top_fallback_reasons'] as Map).isNotEmpty)
              _buildMetricCard('Top Fallback Reasons', [
                ...(stats['top_fallback_reasons'] as Map).entries.map((entry) =>
                    _buildMetricRow(entry.key.toString(), entry.value.toString())),
              ]),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              // Refresh metrics
            });
          },
          child: const Text('Refresh'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildHealthIndicator(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case 'HEALTHY':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'WARNING':
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case 'CRITICAL':
        color = Colors.red;
        icon = Icons.error;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(
            'Status: $status',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
