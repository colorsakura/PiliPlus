import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/shared/widgets/button/icon_button.dart';
import 'package:PiliPlus/shared/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/shared/widgets/self_sized_horizontal_list.dart';
import 'package:PiliPlus/models/common/image_type.dart';
import 'package:PiliPlus/features/contact/contact.dart';
import 'package:PiliPlus/features/share/share.dart';
import 'package:PiliPlus/utils/extension/scroll_controller_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/utils/page_utils.dart';

class SharePanel extends StatefulWidget {
  const SharePanel({
    super.key,
    required this.content,
    this.userList,
  });

  final Map content;
  final List<ShareUserEntity>? userList;

  @override
  State<SharePanel> createState() => _SharePanelState();
}

class _SharePanelState extends State<SharePanel> {
  final List<ShareUserEntity> _userList = <ShareUserEntity>[];
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  // Initialize use case with repository
  late final SendShare _sendShare = SendShare(
    ShareRepositoryImpl(
      remoteDataSource: ShareRemoteDataSourceImpl(),
    ),
  );

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.userList?.isNotEmpty == true) {
      _userList.addAll(widget.userList!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding:
          const EdgeInsets.all(12) +
          MediaQuery.paddingOf(context) +
          MediaQuery.viewInsetsOf(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('分享给'),
              iconButton(
                size: 32,
                iconSize: 18,
                tooltip: '关闭',
                icon: const Icon(Icons.clear),
                onPressed: Get.back,
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: SelfSizedHorizontalList(
                  padding: .zero,
                  itemCount: _userList.length,
                  controller: _scrollController,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final item = _userList[index];
                    return Builder(
                      builder: (context) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              item.selected = !item.selected;
                            });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: SizedBox(
                            width: 65,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.topCenter,
                              children: [
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: NetworkImgLayer(
                                        width: 40,
                                        height: 40,
                                        src: item.avatar,
                                        type: ImageType.avatar,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                if (item.selected)
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withValues(
                                            alpha: 0.3,
                                          ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        width: 1.5,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              GestureDetector(
                onTap: () async {
                  _focusNode.unfocus();
                  final ShareUserEntity? userModel = await Navigator.of(context).push(
                    GetPageRoute(page: () => const ContactPage()),
                  );
                  if (userModel != null) {
                    setState(() {
                      _userList
                        ..remove(userModel)
                        ..insert(0, userModel);
                      _scrollController.jumpToTop();
                    });
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 65,
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.onInverseSurface,
                          ),
                          child: Icon(
                            Icons.person_add_alt,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text('更多', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  minLines: 1,
                  maxLines: 2,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: '说说你的想法吧...',
                    visualDensity: .standard,
                    hintStyle: const TextStyle(fontSize: 14),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    filled: true,
                    isDense: true,
                    contentPadding: const .symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    fillColor: theme.colorScheme.onInverseSurface,
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(100)],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.tonal(
                onPressed: _onSend,
                style: FilledButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: const VisualDensity(
                    horizontal: -2,
                    vertical: -1,
                  ),
                ),
                child: const Text('发送'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _onSend() async {
    final selectedUsers = _userList.where((user) => user.selected).toList();
    if (selectedUsers.isEmpty) {
      SmartDialog.showToast('请选择分享的用户');
      return;
    }
    SmartDialog.showLoading();
    final result = await _sendShare(
      users: selectedUsers,
      content: widget.content,
      message: _controller.text.isNotEmpty ? _controller.text : null,
    );
    SmartDialog.dismiss();

    if (result case Success(:final data)) {
      final successCount = data.values.where((success) => success).length;
      if (successCount == data.length) {
        PageUtils.pop();
        SmartDialog.showToast('分享成功');
      } else if (successCount == 0) {
        SmartDialog.showToast('分享失败');
      } else {
        SmartDialog.showToast('部分分享失败');
      }
    } else {
      SmartDialog.showToast('分享失败');
    }
  }
}
