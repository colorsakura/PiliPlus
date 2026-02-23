import 'dart:convert';

import 'package:PiliPlus/features/about/data/datasources/about_local_datasource.dart';
import 'package:PiliPlus/features/about/domain/entities/app_info.dart';
import 'package:PiliPlus/features/about/domain/entities/cache_info.dart';
import 'package:PiliPlus/features/about/domain/entities/export_data.dart';
import 'package:PiliPlus/features/about/domain/repositories/about_repository.dart';

/// About页面仓库实现
class AboutRepositoryImpl implements AboutRepository {
  final AboutLocalDataSource _localDataSource;

  AboutRepositoryImpl({
    required AboutLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<AppInfoEntity> getAppInfo() async {
    final versionName = _localDataSource.getVersionName();
    final versionCode = _localDataSource.getVersionCode();

    return AppInfoEntity(
      appName: _localDataSource.getAppName(),
      versionName: versionName,
      versionCode: versionCode,
      fullVersion: '$versionName+$versionCode',
      buildTime: _localDataSource.getBuildTime(),
      commitHash: _localDataSource.getCommitHash(),
      sourceCodeUrl: _localDataSource.getSourceCodeUrl(),
    );
  }

  @override
  Future<CacheInfoEntity> getCacheInfo() async {
    final sizeInBytes = await _localDataSource.getCacheSize();
    final formattedSize = _localDataSource.formatCacheSize(sizeInBytes);

    return CacheInfoEntity(
      sizeInBytes: sizeInBytes,
      formattedSize: formattedSize,
    );
  }

  @override
  Future<bool> clearCache() async {
    try {
      await _localDataSource.clearCache();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<ExportDataEntity> exportSettings() async {
    final jsonString = _localDataSource.exportAllSettings();
    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
    return ExportDataEntity(
      jsonData: jsonData,
      dataType: '设置',
      hasLabel: true,
    );
  }

  @override
  Future<bool> importSettings(Map<String, dynamic> jsonData) async {
    try {
      return _localDataSource.importAllJsonSettings(jsonData);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<ExportDataEntity> exportLoginInfo() async {
    final loginData = _localDataSource.getLoginInfo();
    final jsonData = loginData.map(
      (key, value) => MapEntry(key.toString(), value.toJson()),
    );
    return ExportDataEntity(
      jsonData: jsonData,
      dataType: '登录信息',
    );
  }

  @override
  Future<bool> importLoginInfo(Map<String, dynamic> jsonData) async {
    try {
      return await _localDataSource.importLoginInfo(jsonData);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> resetExportableSettings() async {
    try {
      await _localDataSource.resetExportableSettings();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> resetAllData() async {
    try {
      await _localDataSource.resetAllData();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> checkUpdate({bool showMessage = false}) {
    return _localDataSource.checkUpdate(showMessage: showMessage);
  }
}
