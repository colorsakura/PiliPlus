import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, this.userAvatarUrl, required this.isLogin});

  final String? userAvatarUrl;
  final bool isLogin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: GestureDetector(
        child: CircleAvatar(
          radius: 34,
          child: NetworkImgLayer(
            src: userAvatarUrl,
            width: 34,
            height: 34,
          ),
        ),
      ),
    );
  }
}
