import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/live/presentation/providers/live_room_controller.dart';

/// Live Room Page
///
/// Displays live room information including quality options, playback URL, etc.
class LiveRoomPage extends ConsumerStatefulWidget {
  const LiveRoomPage({
    super.key,
    required this.roomId,
    this.qn,
    this.onlyAudio = false,
  });

  final Object roomId;
  final Object? qn;
  final bool onlyAudio;

  @override
  ConsumerState<LiveRoomPage> createState() => _LiveRoomPageState();
}

class _LiveRoomPageState extends ConsumerState<LiveRoomPage> {
  @override
  void initState() {
    super.initState();
    // Load room info on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(liveRoomControllerProvider.notifier)
          .fetchRoomInfo(
            roomId: widget.roomId,
            qn: widget.qn,
            onlyAudio: widget.onlyAudio,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final roomState = ref.watch(liveRoomControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Live Room: ${widget.roomId}'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(liveRoomControllerProvider.notifier)
              .fetchRoomInfo(
                roomId: widget.roomId,
                qn: widget.qn,
                onlyAudio: widget.onlyAudio,
              );
        },
        child: _buildBody(roomState),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref
              .read(liveRoomControllerProvider.notifier)
              .fetchRoomInfo(
                roomId: widget.roomId,
                qn: widget.qn,
                onlyAudio: widget.onlyAudio,
              );
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildBody(LiveRoomState state) {
    if (state.isLoading && state.roomInfo == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.roomInfo == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.errorMessage}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(liveRoomControllerProvider.notifier)
                    .fetchRoomInfo(
                      roomId: widget.roomId,
                      qn: widget.qn,
                      onlyAudio: widget.onlyAudio,
                    );
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final roomInfo = state.roomInfo;
    if (roomInfo == null) {
      return const Center(child: Text('No room info available'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection('Room Information', [
          _buildInfoItem('Room ID', widget.roomId.toString()),
          _buildInfoItem('Quality', widget.qn?.toString() ?? 'Default'),
          _buildInfoItem('Audio Only', widget.onlyAudio ? 'Yes' : 'No'),
        ]),
        const SizedBox(height: 16),
        _buildSection('Play URL Info', [
          _buildJsonItem('playurl_info', roomInfo['playurl_info']),
        ]),
        const SizedBox(height: 16),
        _buildSection('Additional Info', [
          ...roomInfo.keys
              .where((key) => key != 'playurl_info')
              .map((key) => _buildJsonItem(key, roomInfo[key])),
        ]),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
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

  Widget _buildInfoItem(String label, String value) {
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

  Widget _buildJsonItem(String key, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            key,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value?.toString() ?? 'null',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
