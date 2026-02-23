import 'package:PiliPlus/features/about/domain/repositories/about_repository.dart';

/// 导入设置用例
class ImportSettingsUseCase {
  final AboutRepository _repository;

  const ImportSettingsUseCase(this._repository);

  Future<bool> call(Map<String, dynamic> jsonData) {
    return _repository.importSettings(jsonData);
  }
}
