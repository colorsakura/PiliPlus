import 'package:PiliPlus/features/backup/domain/entities/webdav_config.dart';
import 'package:PiliPlus/features/backup/providers/domain_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Backup 状态
class BackupState {
  final WebDavConfig config;
  final bool isLoading;
  final bool obscureText;
  final String? errorMessage;

  const BackupState({
    required this.config,
    this.isLoading = false,
    this.obscureText = true,
    this.errorMessage,
  });

  BackupState copyWith({
    WebDavConfig? config,
    bool? isLoading,
    bool? obscureText,
    String? errorMessage,
  }) {
    return BackupState(
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      obscureText: obscureText ?? this.obscureText,
      errorMessage: errorMessage,
    );
  }
}

/// Backup Controller (使用 Riverpod 3.x 的 Notifier)
///
/// 通过 ref 直接访问 Provider Container 获取依赖
class BackupController extends Notifier<BackupState> {
  // 使用 getter 延迟获取依赖,避免在 build 中直接初始化
  InitializeWebDavUseCase get _initializeWebDavUseCase =>
      ref.read(initializeWebDavUseCaseProvider);
  BackupSettingsUseCase get _backupSettingsUseCase =>
      ref.read(backupSettingsUseCaseProvider);
  RestoreSettingsUseCase get _restoreSettingsUseCase =>
      ref.read(restoreSettingsUseCaseProvider);
  GetWebDavConfigUseCase get _getWebDavConfigUseCase =>
      ref.read(getWebDavConfigUseCaseProvider);
  SaveWebDavConfigUseCase get _saveWebDavConfigUseCase =>
      ref.read(saveWebDavConfigUseCaseProvider);

  @override
  BackupState build() {
    // 加载初始配置
    final config = _getWebDavConfigUseCase();
    return BackupState(config: config);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscureText: !state.obscureText);
  }

  void updateUri(String uri) {
    state = state.copyWith(
      config: state.config.copyWith(uri: uri),
    );
  }

  void updateUsername(String username) {
    state = state.copyWith(
      config: state.config.copyWith(username: username),
    );
  }

  void updatePassword(String password) {
    state = state.copyWith(
      config: state.config.copyWith(password: password),
    );
  }

  void updateDirectory(String directory) {
    state = state.copyWith(
      config: state.config.copyWith(directory: directory),
    );
  }

  /// 保存配置
  Future<bool> saveConfig() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    if (state.config.uri.isEmpty) {
      await _saveWebDavConfigUseCase(state.config);
      state = state.copyWith(isLoading: false);
      return true;
    }

    final result = await _initializeWebDavUseCase(state.config);

    if (result.success) {
      await _saveWebDavConfigUseCase(state.config);
      state = state.copyWith(isLoading: false);
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.message ?? '配置失败',
      );
      return false;
    }
  }

  /// 备份设置
  Future<void> backup() async {
    if (state.isLoading) return;

    // 如果 URI 为空，提示用户先配置
    if (state.config.uri.isEmpty) {
      state = state.copyWith(errorMessage: '请先配置 WebDAV 信息');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    
    // 先确保 WebDAV 已初始化
    final initResult = await _initializeWebDavUseCase(state.config);
    if (!initResult.success) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: initResult.message ?? 'WebDAV 初始化失败',
      );
      return;
    }
    
    // 执行备份
    final result = await _backupSettingsUseCase();

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.success ? null : result.message,
    );
  }

  /// 恢复设置
  Future<void> restore() async {
    if (state.isLoading) return;

    // 如果 URI 为空，提示用户先配置
    if (state.config.uri.isEmpty) {
      state = state.copyWith(errorMessage: '请先配置 WebDAV 信息');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    
    // 先确保 WebDAV 已初始化
    final initResult = await _initializeWebDavUseCase(state.config);
    if (!initResult.success) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: initResult.message ?? 'WebDAV 初始化失败',
      );
      return;
    }
    
    // 执行恢复
    final result = await _restoreSettingsUseCase();

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.success ? null : result.message,
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
