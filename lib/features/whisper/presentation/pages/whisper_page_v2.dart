import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/whisper/presentation/providers/whisper_session_controller.dart';
import 'package:PiliPlus/features/whisper/presentation/widgets/item.dart';
import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart' show Session;

/// Whisper Page (Riverpod version)
///
/// Displays whisper (private message) sessions
class WhisperPageV2 extends ConsumerStatefulWidget {
  const WhisperPageV2({super.key});

  @override
  ConsumerState<WhisperPageV2> createState() => _WhisperPageV2State();
}

class _WhisperPageV2State extends ConsumerState<WhisperPageV2> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMore();
    }
  }

  void _loadMore() {
    // TODO: Implement pagination
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(whisperSessionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
        actions: [
          IconButton(
            onPressed: () {
              ref
                  .read(whisperSessionControllerProvider.notifier)
                  .fetchSessions();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(sessionState),
    );
  }

  Widget _buildBody(WhisperSessionState state) {
    if (state.isLoading && state.sessions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.errorMessage}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(whisperSessionControllerProvider.notifier)
                    .fetchSessions();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.sessions.isEmpty) {
      return const Center(child: Text('No messages'));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.sessions.length,
      itemBuilder: (context, index) {
        final session = state.sessions[index];
        if (session is Session) {
          return _buildSessionItem(session);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSessionItem(Session session) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(session.face ?? ''),
        ),
        title: Text(session.name ?? 'Unknown'),
        subtitle: Text(
          session.lastMsg ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: session.unread?.unreadCount != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  (session.unread!.unreadCount! > 99
                          ? '99+'
                          : session.unread!.unreadCount.toString())
                      .toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              )
            : null,
      ),
    );
  }
}
