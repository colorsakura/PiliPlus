import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/contact/domain/entities/contact_config.dart';
import 'package:PiliPlus/features/share/share.dart' show UserModel;

part 'contact_controller.g.dart';

/// 联系人页面控制器
@riverpod
class ContactController extends _$ContactController {
  @override
  ContactConfig build() {
    // TODO: Get userId from Accounts.main.mid
    return const ContactConfig(
      isFromSelect: true,
      userId: 0, // Will be set from init
    );
  }

  /// 初始化配置
  void initConfig({bool isFromSelect = true, required int userId}) {
    state = ContactConfig(
      isFromSelect: isFromSelect,
      userId: userId,
    );
  }

  /// 处理用户选择
  UserModel? onSelect(UserModel userModel) {
    if (state.isFromSelect) {
      return userModel; // Signal to pop with result
    }
    return null; // No action needed
  }
}
