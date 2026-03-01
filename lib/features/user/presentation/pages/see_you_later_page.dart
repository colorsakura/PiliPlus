import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/user/presentation/providers/see_you_later_controller.dart';
import 'package:PiliPlus/models/later/list.dart';

/// See You Later Page
///
/// Displays "See You Later" (watch later) list
class SeeYouLaterPage extends ConsumerStatefulWidget {
  const SeeYouLaterPage({
    super.key,
    this.viewed = 0,
    this.keyword = '',
    this.asc = false,
  });

  final int viewed;
  final String keyword;
  final bool asc;

  @override
  ConsumerState<SeeYouLaterPage> createState() => _SeeYouLaterPageState();
}

class _SeeYouLaterPageState extends ConsumerState<SeeYouLaterPage> {
  @override
  void initState() {
    super.initState();
    // Load data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(seeYouLaterControllerProvider.notifier)
          .fetchSeeYouLater(
            page: 1,
            viewed: widget.viewed,
            keyword: widget.keyword,
            asc: widget.asc,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final seeYouLaterState = ref.watch(seeYouLaterControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('See You Later'),
      ),
      body: _buildBody(seeYouLaterState),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref
              .read(seeYouLaterControllerProvider.notifier)
              .fetchSeeYouLater(
                page: 1,
                viewed: widget.viewed,
                keyword: widget.keyword,
                asc: widget.asc,
              );
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildBody(SeeYouLaterState state) {
    if (state.isLoading && state.laterData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.laterData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.errorMessage}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(seeYouLaterControllerProvider.notifier)
                    .fetchSeeYouLater(
                      page: 1,
                      viewed: widget.viewed,
                      keyword: widget.keyword,
                      asc: widget.asc,
                    );
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final items = state.laterData?.list ?? [];

    if (items.isEmpty) {
      return const Center(child: Text('No items in watch later'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(seeYouLaterControllerProvider.notifier)
            .fetchSeeYouLater(
              page: 1,
              viewed: widget.viewed,
              keyword: widget.keyword,
              asc: widget.asc,
            );
      },
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _SeeYouLaterItemCard(item: items[index]);
        },
      ),
    );
  }
}

class _SeeYouLaterItemCard extends StatelessWidget {
  final LaterItemModel item;

  const _SeeYouLaterItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title ?? 'No title',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              item.owner?.name ?? 'Unknown author',
              style: const TextStyle(color: Colors.grey),
            ),
            if (item.pubdate != null) ...[
              const SizedBox(height: 4),
              Text(
                _formatTimestamp(item.pubdate!),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
