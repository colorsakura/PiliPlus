import 'package:PiliPlus/common/widgets/button/icon_button.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/common/widgets/self_sized_horizontal_list.dart';
import 'package:PiliPlus/models/common/image_type.dart';
import 'package:PiliPlus/features/contact/contact.dart';
import 'package:PiliPlus/utils/extension/scroll_controller_ext.dart';
import 'package:PiliPlus/utils/request_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

/// User model for sharing
class UserModel {
  UserModel({
    required this.mid,
    required this.name,
    required this.avatar,
    this.selected = false,
  });

  final int mid;
  final String name;
  final String avatar;
  bool selected;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is UserModel) {
      return mid == other.mid;
    }
    return false;
  }

  @override
  int get hashCode => mid.hashCode;
}

/// Share panel widget
class SharePanel extends StatefulWidget {
  const SharePanel({
    super.key,
    required this.content,
    this.userList,
  });

  final Map content;
  final List<UserModel>? userList;

  @override
  State<SharePanel> createState() => _SharePanelState();
}

class _SharePanelState extends State<SharePanel> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shareData = Get.arguments;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        // ... share UI implementation
        // (This is a simplified version - the original has more widgets)
        const SizedBox(height: 20),
      ],
    );
  }
}
