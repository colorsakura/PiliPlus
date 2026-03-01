import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/msg/presentation/providers/msg_unread_controller.dart';
import 'package:PiliPlus/features/msg/presentation/providers/msg_reply_controller.dart';
import 'package:PiliPlus/features/msg/presentation/providers/msg_at_controller.dart';
import 'package:PiliPlus/features/msg/presentation/providers/msg_like_controller.dart';

/// Message List Page
///
/// Unified page for viewing all message types (reply, at, like)
class MsgListPage extends ConsumerStatefulWidget {
  const MsgListPage({
    super.key,
    this.initialTabIndex = 0,
  });

  final int initialTabIndex;

  @override
  ConsumerState<MsgListPage> createState() => _MsgListPageState();
}

class _MsgListPageState extends ConsumerState<MsgListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );

    // Load initial data
    _loadInitialData();
  }

  void _loadInitialData() {
    final replyState = ref.read(msgReplyControllerProvider);
    final atState = ref.read(msgAtControllerProvider);
    final likeState = ref.read(msgLikeControllerProvider);

    if (replyState.items == null) {
      ref.read(msgReplyControllerProvider.notifier).fetchReplyMessages();
    }
    if (atState.items == null) {
      ref.read(msgAtControllerProvider.notifier).fetchAtMessages();
    }
    if (likeState.items == null) {
      ref.read(msgLikeControllerProvider.notifier).fetchLikeMessages();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unreadState = ref.watch(msgUnreadControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: _buildTabWithBadge('Reply', unreadState.replyUnread),
            ),
            Tab(
              child: _buildTabWithBadge('@ Me', unreadState.atUnread),
            ),
            Tab(
              child: _buildTabWithBadge('Like', unreadState.likeUnread),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(msgUnreadControllerProvider.notifier).fetchUnread();
              _refreshCurrentTab();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ReplyMessagesTab(),
          _AtMessagesTab(),
          _LikeMessagesTab(),
        ],
      ),
    );
  }

  Widget _buildTabWithBadge(String label, int unreadCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label),
        if (unreadCount > 0) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(
              minWidth: 18,
              minHeight: 18,
            ),
            child: Text(
              unreadCount > 99 ? '99+' : unreadCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  void _refreshCurrentTab() {
    switch (_tabController.index) {
      case 0:
        ref.read(msgReplyControllerProvider.notifier).refresh();
        break;
      case 1:
        ref.read(msgAtControllerProvider.notifier).refresh();
        break;
      case 2:
        ref.read(msgLikeControllerProvider.notifier).refresh();
        break;
    }
  }
}

/// Reply messages tab
class _ReplyMessagesTab extends ConsumerWidget {
  const _ReplyMessagesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final replyState = ref.watch(msgReplyControllerProvider);

    return _MessageListWidget(
      state: replyState,
      onLoadMore: () {
        ref.read(msgReplyControllerProvider.notifier).loadMore();
      },
      onRefresh: () {
        return ref.read(msgReplyControllerProvider.notifier).refresh();
      },
      itemBuilder: (context, index, item) {
        return _ReplyMessageCard(item: item);
      },
    );
  }
}

/// At messages tab
class _AtMessagesTab extends ConsumerWidget {
  const _AtMessagesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final atState = ref.watch(msgAtControllerProvider);

    return _MessageListWidget(
      state: atState,
      onLoadMore: () {
        ref.read(msgAtControllerProvider.notifier).loadMore();
      },
      onRefresh: () {
        return ref.read(msgAtControllerProvider.notifier).refresh();
      },
      itemBuilder: (context, index, item) {
        return _AtMessageCard(item: item);
      },
    );
  }
}

/// Like messages tab
class _LikeMessagesTab extends ConsumerWidget {
  const _LikeMessagesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likeState = ref.watch(msgLikeControllerProvider);

    return _MessageListWidget(
      state: likeState,
      onLoadMore: () {
        ref.read(msgLikeControllerProvider.notifier).loadMore();
      },
      onRefresh: () {
        return ref.read(msgLikeControllerProvider.notifier).refresh();
      },
      itemBuilder: (context, index, item) {
        return _LikeMessageCard(item: item);
      },
    );
  }
}

/// Generic message list widget
class _MessageListWidget<T> extends StatelessWidget {
  const _MessageListWidget({
    required this.state,
    required this.onLoadMore,
    required this.onRefresh,
    required this.itemBuilder,
  });

  final dynamic state;
  final VoidCallback onLoadMore;
  final Future<void> Function() onRefresh;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;

  @override
  Widget build(BuildContext context) {
    final items = state.items as List<T>?;
    final isLoading = state.isLoading as bool;
    final errorMessage = state.errorMessage as String?;

    if (items == null && isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null && items == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => onRefresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (items == null || items.isEmpty) {
      return const Center(child: Text('No messages'));
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index >= items.length) {
            // Loading indicator at the end
            if (state.hasMore as bool && !isLoading) {
              onLoadMore();
            }
            return isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : const SizedBox.shrink();
          }

          return itemBuilder(context, index, items[index]);
        },
      ),
    );
  }
}

/// Reply message card
class _ReplyMessageCard extends StatelessWidget {
  const _ReplyMessageCard({required this.item});

  final dynamic item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(item.reply?.face ?? ''),
        ),
        title: Text(item.reply?.uname ?? 'Unknown'),
        subtitle: Text(
          item.item?.sourceContent ?? 'No content',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(_formatTime(item.likeTime)),
      ),
    );
  }

  String _formatTime(int? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.month}/${date.day}';
  }
}

/// At message card
class _AtMessageCard extends StatelessWidget {
  const _AtMessageCard({required this.item});

  final dynamic item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(item.user?.face ?? ''),
        ),
        title: Text(item.user?.uname ?? 'Unknown'),
        subtitle: Text(
          item.item?.sourceContent ?? 'No content',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(_formatTime(item.atTime)),
      ),
    );
  }

  String _formatTime(int? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.month}/${date.day}';
  }
}

/// Like message card
class _LikeMessageCard extends StatelessWidget {
  const _LikeMessageCard({required this.item});

  final dynamic item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(item.users?.first?.face ?? ''),
        ),
        title: Text(item.users?.first?.uname ?? 'Unknown'),
        subtitle: Text(
          item.item?.sourceContent ?? 'No content',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(_formatTime(item.likeTime)),
      ),
    );
  }

  String _formatTime(int? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.month}/${date.day}';
  }
}
