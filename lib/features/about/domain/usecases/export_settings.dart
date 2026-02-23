import 'package:PiliPlus/features/about/domain/entities/export_data.dart';
import 'package:PiliPlus/features/about/domain/repositories/about_repository.dart';

/// 导出设置用例
class ExportSettingsUseCase {
  final AboutRepository _repository;

  const ExportSettingsUseCase(this._repository);

  Future<ExportDataEntity> call() {
    return _repository.exportSettings();
  }
}
