import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/reply/presentation/providers/reply_list_controller.dart';

/// Reply List Page
///
/// Displays replies for a specific content (video, article, etc.)
class ReplyListPage extends ConsumerStatefulWidget {
  const ReplyListPage({
    super.key,
    required this.oid,
    required this.type,
    this.sort = 1,
  });

  final int oid;
  final int type;
  final int sort;

  @override
  ConsumerState<ReplyListPage> createState() => _ReplyListPageState();
}

class _ReplyListPageState extends ConsumerState<ReplyListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReplies();
    });
  }

  void _loadReplies() {
    ref
        .read(replyListControllerProvider.notifier)
        .fetchReplyList(
          isLogin: true,
          oid: widget.oid,
          nextOffset: '',
          type: widget.type,
          page: 1,
          sort: widget.sort,
        );
  }

  @override
  Widget build(BuildContext context) {
    final replyState = ref.watch(replyListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Replies - Type ${widget.type}'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadReplies();
        },
        child: _buildBody(replyState),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadReplies,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildBody(ReplyListState state) {
    if (state.isLoading && state.replyData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.replyData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.errorMessage}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadReplies,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final replies = state.replyData?.replies;
    if (replies == null || replies.isEmpty) {
      return const Center(child: Text('No replies yet'));
    }

    return ListView.builder(
      itemCount: replies.length,
      itemBuilder: (context, index) {
        return _ReplyCard(reply: replies[index]);
      },
    );
  }
}

class _ReplyCard extends StatelessWidget {
  final dynamic reply;

  const _ReplyCard({required this.reply});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(reply.member?.avatar ?? ''),
        ),
        title: Text(reply.member?.uname ?? 'Unknown'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reply.content?.message != null)
              Text(
                reply.content?.message ?? '',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.thumb_up, size: 14),
                const SizedBox(width: 4),
                Text(reply.like?.toString() ?? '0'),
                const SizedBox(width: 16),
                const Icon(Icons.comment, size: 14),
                const SizedBox(width: 4),
                Text(reply.rcount?.toString() ?? '0'),
              ],
            ),
          ],
        ),
        trailing: Text(
          _formatTime(reply.ctime),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }

  String _formatTime(int? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}
