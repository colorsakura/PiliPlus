import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:PiliPlus/utils/beta_testing_manager.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:flutter/material.dart';

/// Development controls for Week 2-3 Beta Testing.
///
/// This widget provides UI controls for:
/// - Enabling/disabling beta testing
/// - Setting rollout percentage
/// - Viewing beta status
/// - Triggering emergency rollout
/// - Increasing rollout percentage
///
/// **Usage:**
/// ```dart
/// // In development settings page
/// if (kDebugMode) {
///   BetaTestingControlsWidget();
/// }
/// ```
class BetaTestingControlsWidget extends StatefulWidget {
  const BetaTestingControlsWidget({super.key});

  @override
  State<BetaTestingControlsWidget> createState() => _BetaTestingControlsWidgetState();
}

class _BetaTestingControlsWidgetState extends State<BetaTestingControlsWidget> {
  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    final betaEnabled = GStorage.setting.get(
      SettingBoxKey.betaTestingEnabled,
      defaultValue: false,
    );

    final rolloutPercent = GStorage.setting.get(
      SettingBoxKey.betaRolloutPercentage,
      defaultValue: 10,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Divider(),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Week 2-3 Beta Testing (Development)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Enable Beta Testing'),
          subtitle: Text('Current rollout: $rolloutPercent% of beta users'),
          value: betaEnabled,
          onChanged: (value) {
            setState(() {
              GStorage.setting.put(SettingBoxKey.betaTestingEnabled, value);
              if (kDebugMode) {
                debugPrint('[BetaTesting] Beta testing ${value ? "enabled" : "disabled"}');
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(value ? 'Beta testing enabled' : 'Beta testing disabled'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
        if (betaEnabled) ...[
          ListTile(
            title: const Text('Adjust Rollout Percentage'),
            subtitle: Text('Current: $rolloutPercent%'),
            leading: const Icon(Icons.pie_chart),
            onTap: () => _showRolloutDialog(context, rolloutPercent),
          ),
          ListTile(
            title: const Text('View Beta Status'),
            subtitle: const Text('See current beta testing status and metrics'),
            leading: const Icon(Icons.analytics),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const BetaStatusDialog(),
              );
            },
          ),
          ListTile(
            title: const Text('Increase Rollout'),
            subtitle: const Text('Gradually increase rollout percentage'),
            leading: const Icon(Icons.trending_up),
            onTap: () => _showIncreaseDialog(context, rolloutPercent),
          ),
          ListTile(
            title: const Text(
              'Emergency Rollout',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text(
              'Disable Rust API and revert to Flutter',
              style: TextStyle(color: Colors.red),
            ),
            leading: const Icon(Icons.emergency, color: Colors.red),
            onTap: () => _showEmergencyRolloutDialog(context),
          ),
        ],
      ],
    );
  }

  void _showRolloutDialog(BuildContext context, int currentPercent) {
    final controller = TextEditingController(text: currentPercent.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Rollout Percentage'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Percentage (0-100)',
            suffixText: '%',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newPercent = int.tryParse(controller.text);
              if (newPercent != null && newPercent >= 0 && newPercent <= 100) {
                GStorage.setting.put(
                  SettingBoxKey.betaRolloutPercentage,
                  newPercent,
                );
                setState(() {});
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Rollout set to $newPercent%'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid percentage (0-100)'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }

  void _showIncreaseDialog(BuildContext context, int currentPercent) {
    final options = [10, 25, 50, 75, 100]
        .where((p) => p > currentPercent)
        .toList();

    if (options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Already at maximum rollout (100%)'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Increase Rollout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current: $currentPercent%'),
            const SizedBox(height: 16),
            const Text('Select new percentage:'),
            const SizedBox(height: 8),
            ...options.map((percent) => ListTile(
                  title: Text('$percent%'),
                  onTap: () {
                    Navigator.of(context).pop();
                    final success = BetaTestingManager.increaseRolloutPercentage(percent);
                    if (success) {
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Rollout increased to $percent%'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to increase rollout'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyRolloutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Emergency Rollout',
          style: TextStyle(color: Colors.red),
        ),
        content: const Text(
          'This will immediately disable the Rust API and revert all users to the Flutter implementation.\n\n'
          'Use this only if critical issues are detected.\n\n'
          'Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await BetaTestingManager.emergencyRollout(
                reason: 'Manual emergency rollout triggered by developer',
              );
              setState(() {});
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Emergency rollout complete'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('EMERGENCY ROLLBACK'),
          ),
        ],
      ),
    );
  }
}

/// Dialog displaying current beta testing status.
class BetaStatusDialog extends StatefulWidget {
  const BetaStatusDialog({super.key});

  @override
  State<BetaStatusDialog> createState() => _BetaStatusDialogState();
}

class _BetaStatusDialogState extends State<BetaStatusDialog> {
  @override
  Widget build(BuildContext context) {
    final status = BetaTestingManager.getStatus();
    final report = BetaTestingManager.getSummaryReport();

    return AlertDialog(
      title: const Text('Beta Testing Status'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusRow('Beta Testing', status['beta_testing_enabled'] ? '✅ Enabled' : '❌ Disabled'),
            _buildStatusRow('Rollout Percentage', '${status['rollout_percentage']}%'),
            _buildStatusRow('In Beta Cohort', status['is_in_beta_cohort'] ? '✅ Yes' : '❌ No'),
            _buildStatusRow('Rust API Enabled', status['rust_api_enabled'] ? '✅ Yes' : '❌ No'),
            _buildStatusRow('User ID', status['user_id'].toString().substring(0, 20) + '...'),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              report,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              // Refresh status
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

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }
}
