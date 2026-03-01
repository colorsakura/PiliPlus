import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/user/presentation/providers/user_info_controller.dart';

/// User Info Page
///
/// Displays user navigation information including coins, level, VIP status, etc.
class UserInfoPage extends ConsumerWidget {
  const UserInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfoState = ref.watch(userInfoControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Info'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(userInfoControllerProvider.notifier)
              .fetchUserInfo(forceRefresh: true);
        },
        child: _buildBody(userInfoState, ref),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(userInfoControllerProvider.notifier).fetchUserInfo();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildBody(UserInfoState state, WidgetRef ref) {
    if (state.isLoading && state.userInfo == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.userInfo == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.errorMessage}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(userInfoControllerProvider.notifier).fetchUserInfo();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final userInfo = state.userInfo;
    if (userInfo == null) {
      return const Center(child: Text('No user info available'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard('Basic Info', [
          _buildInfoRow('Username', userInfo.uname ?? 'N/A'),
          _buildInfoRow('Mid', userInfo.mid?.toString() ?? 'N/A'),
          _buildInfoRow('Money', userInfo.money?.toString() ?? 'N/A'),
          _buildInfoRow('Scores', userInfo.scores?.toString() ?? 'N/A'),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('Level', [
          _buildInfoRow(
            'Current Level',
            userInfo.levelInfo?.currentLevel?.toString() ?? 'N/A',
          ),
          _buildInfoRow(
            'Exp',
            userInfo.levelInfo?.currentExp?.toString() ?? 'N/A',
          ),
          _buildInfoRow(
            'Next Level',
            userInfo.levelInfo?.nextExp?.toString() ?? 'N/A',
          ),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('VIP', [
          _buildInfoRow('VIP Type', userInfo.vipType?.toString() ?? 'N/A'),
          _buildInfoRow('VIP Status', userInfo.vipStatus?.toString() ?? 'N/A'),
        ]),
      ],
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
