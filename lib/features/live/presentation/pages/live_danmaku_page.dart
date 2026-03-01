import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/live/presentation/providers/live_danmaku_controller.dart';

/// Live Danmaku Page
///
/// Test page for sending danmaku (chat messages) to live rooms
class LiveDanmakuPage extends ConsumerStatefulWidget {
  const LiveDanmakuPage({
    super.key,
    required this.roomId,
  });

  final Object roomId;

  @override
  ConsumerState<LiveDanmakuPage> createState() => _LiveDanmakuPageState();
}

class _LiveDanmakuPageState extends ConsumerState<LiveDanmakuPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<String> _messageHistory = [];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    ref
        .read(liveDanmakuControllerProvider.notifier)
        .sendDanmaku(
          roomId: widget.roomId,
          msg: message,
        )
        .then((success) {
          if (success) {
            setState(() {
              _messageHistory.add('✓ $message');
              _messageController.clear();
            });
            _scrollToBottom();
          } else {
            final danmakuState = ref.read(liveDanmakuControllerProvider);
            setState(() {
              _messageHistory.add(
                '✗ $message - ${danmakuState.errorMessage ?? "Failed"}',
              );
            });
            _scrollToBottom();
          }
        });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final danmakuState = ref.watch(liveDanmakuControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Danmaku Test - Room ${widget.roomId}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messageHistory.isEmpty
                ? const Center(
                    child: Text(
                      'No messages yet\nSend a message to get started',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messageHistory.length,
                    itemBuilder: (context, index) {
                      final message = _messageHistory[index];
                      final isSuccess = message.startsWith('✓');
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSuccess ? '✓' : '✗',
                              style: TextStyle(
                                color: isSuccess ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                message.substring(2),
                                style: TextStyle(
                                  color: isSuccess
                                      ? Colors.black87
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Enter message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      enabled: !danmakuState.isSending,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: danmakuState.isSending ? null : _sendMessage,
                    icon: danmakuState.isSending
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
