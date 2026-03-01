import 'package:PiliPlus/models/common/image_type.dart';
import 'package:PiliPlus/shared/widgets/image/network_img_layer.dart';
import 'package:flutter/material.dart';

/// 用户头像按钮
///
/// 显示用户头像或默认图标，处理登录/未登录状态
class UserAvatarButton extends StatelessWidget {
  const UserAvatarButton({
    super.key,
    required this.isLogin,
    this.faceUrl,
    required this.onTap,
  });

  static const double _avatarSize = 34.0;

  final bool isLogin;
  final String? faceUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: "我的",
      button: true,
      hint: isLogin ? "查看个人中心" : "登录",
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(7), // Ensure 48x48 touch target
          child: isLogin
              ? NetworkImgLayer(
                  type: ImageType.avatar,
                  width: _avatarSize,
                  height: _avatarSize,
                  src: faceUrl,
                )
              : Icon(
                  Icons.person_outline,
                  size: _avatarSize,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
        ),
      ),
    );
  }
}
