import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/user/presentation/providers/user_stat_controller.dart';

/// User Stat Page
///
/// Displays user statistics including follower count, etc.
class UserStatPage extends ConsumerStatefulWidget {
  const UserStatPage({
    super.key,
    this.isOwner = true,
  });

  final bool isOwner;

  @override
  ConsumerState<UserStatPage> createState() => _UserStatPageState();
}

class _UserStatPageState extends ConsumerState<UserStatPage> {
  @override
  void initState() {
    super.initState();
    // Load data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(userStatControllerProvider.notifier)
          .fetchUserStat(
            isOwner: widget.isOwner,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final userStatState = ref.watch(userStatControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isOwner ? 'My Statistics' : 'User Statistics'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(userStatControllerProvider.notifier)
              .fetchUserStat(
                isOwner: widget.isOwner,
              );
        },
        child: _buildBody(userStatState),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref
              .read(userStatControllerProvider.notifier)
              .fetchUserStat(
                isOwner: widget.isOwner,
              );
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildBody(UserStatState state) {
    if (state.isLoading && state.userStat == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.userStat == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.errorMessage}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(userStatControllerProvider.notifier)
                    .fetchUserStat(
                      isOwner: widget.isOwner,
                    );
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final userStat = state.userStat;
    if (userStat == null) {
      return const Center(child: Text('No statistics available'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard('Following', userStat.following?.toString() ?? 'N/A'),
        const SizedBox(height: 16),
        _buildStatCard('Follower', userStat.follower?.toString() ?? 'N/A'),
        const SizedBox(height: 16),
        _buildStatCard(
          'Dynamic Count',
          userStat.dynamicCount?.toString() ?? 'N/A',
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
