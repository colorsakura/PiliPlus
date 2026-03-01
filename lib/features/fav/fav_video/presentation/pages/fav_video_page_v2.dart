import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/fav/fav_video/presentation/providers/fav_folder_list_controller.dart';
import 'package:PiliPlus/models/fav/fav_folder/list.dart';

/// Fav Video Page (Riverpod version)
///
/// Displays favorite video folders
class FavVideoPageV2 extends ConsumerStatefulWidget {
  const FavVideoPageV2({super.key});

  @override
  ConsumerState<FavVideoPageV2> createState() => _FavVideoPageV2State();
}

class _FavVideoPageV2State extends ConsumerState<FavVideoPageV2> {
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
    ref
        .read(favFolderListControllerProvider.notifier)
        .fetchFolders(
          isRefresh: false,
        );
  }

  @override
  Widget build(BuildContext context) {
    final folderState = ref.watch(favFolderListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('收藏夹'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(favFolderListControllerProvider.notifier)
              .fetchFolders(isRefresh: true);
        },
        child: _buildBody(folderState),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref
              .read(favFolderListControllerProvider.notifier)
              .fetchFolders(isRefresh: true);
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildBody(FavFolderListState state) {
    if (state.isLoading && state.folders == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.folders == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.errorMessage}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(favFolderListControllerProvider.notifier)
                    .fetchFolders(isRefresh: true);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final folders = state.folders ?? [];
    if (folders.isEmpty) {
      return const Center(child: Text('暂无收藏夹'));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: folders.length + 1,
      itemBuilder: (context, index) {
        if (index >= folders.length) {
          // Loading indicator at the end
          if (state.isEnd) {
            return const SizedBox.shrink();
          }
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return _FavFolderCard(folder: folders[index]);
      },
    );
  }
}

class _FavFolderCard extends StatelessWidget {
  const _FavFolderCard({required this.folder});

  final FavFolderInfo folder;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(folder.title?[0] ?? 'F'),
        ),
        title: Text(folder.title ?? '未命名收藏夹'),
        subtitle: Text('${folder.mediaCount} 个视频'),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey,
        ),
        onTap: () {
          // TODO: Navigate to folder detail
        },
      ),
    );
  }
}
