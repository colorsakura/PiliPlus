import 'package:PiliPlus/features/login/data/models/login_model.dart';
import 'package:PiliPlus/features/login/domain/entities/login_entity.dart';

/// 登录实体与模型转换器
class LoginMapper {
  /// 将 Model 转换为 Entity
  static LoginEntity toEntity(LoginModel model) {
    return model.toEntity();
  }

  /// 将 Entity 转换为 Model（如果需要）
  static LoginModel toModel(LoginEntity entity) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return LoginModel(
      userId: entity.userId,
      accessToken: entity.accessToken,
      refreshToken: entity.refreshToken,
      expiresIn: entity.expiresIn - now,
    );
  }
}
