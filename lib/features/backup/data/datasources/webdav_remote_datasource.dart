import 'dart:typed_data';

import 'package:PiliPlus/common/widgets/pair.dart';
import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

/// WebDAV 远程数据源接口
abstract interface class WebDavRemoteDataSource {
  Future<Pair<bool, String?>> initialize({
    required String uri,
    required String username,
    required String password,
    required String directory,
  });

  Future<void> uploadFile(String path, Uint8List data);

  Future<Uint8List> downloadFile(String path);

  Future<void> createDirectory(String path);
}

/// WebDAV 远程数据源实现（单例）
class WebDavRemoteDataSourceImpl implements WebDavRemoteDataSource {
  WebDavRemoteDataSourceImpl._internal();
  
  static final WebDavRemoteDataSourceImpl _instance = 
      WebDavRemoteDataSourceImpl._internal();
  
  static WebDavRemoteDataSourceImpl get instance => _instance;

  webdav.Client? _client;
  String _fullDirectory = '';
  String? _lastUri;
  String? _lastUsername;
  String? _lastPassword;
  String? _lastDirectory;

  @override
  Future<Pair<bool, String?>> initialize({
    required String uri,
    required String username,
    required String password,
    required String directory,
  }) async {
    // 保存配置以便后续使用
    _lastUri = uri;
    _lastUsername = username;
    _lastPassword = password;
    _lastDirectory = directory;

    String webDavDirectory = directory;
    if (!webDavDirectory.endsWith('/')) {
      webDavDirectory += '/';
    }
    _fullDirectory = '$webDavDirectory${Constants.appName}';

    try {
      _client = null;
      final client =
          webdav.newClient(
              uri,
              user: username,
              password: password,
            )
            ..setHeaders({'accept-charset': 'utf-8'})
            ..setConnectTimeout(12000)
            ..setReceiveTimeout(12000)
            ..setSendTimeout(12000);

      await client.mkdirAll(_fullDirectory);

      _client = client;
      return Pair(first: true, second: null);
    } catch (e) {
      return Pair(first: false, second: e.toString());
    }
  }

  /// 确保客户端已初始化
  Future<void> _ensureInitialized() async {
    if (_client == null) {
      if (_lastUri == null || _lastUri!.isEmpty) {
        throw Exception('请先配置 WebDAV 信息');
      }
      await initialize(
        uri: _lastUri!,
        username: _lastUsername!,
        password: _lastPassword!,
        directory: _lastDirectory!,
      );
    }
  }

  @override
  Future<void> uploadFile(String path, Uint8List data) async {
    await _ensureInitialized();

    final fullPath = '$_fullDirectory/$path';

    // 尝试删除旧文件
    try {
      await _client!.remove(fullPath);
    } catch (_) {}

    await _client!.write(fullPath, data);
  }

  @override
  Future<Uint8List> downloadFile(String path) async {
    await _ensureInitialized();

    final fullPath = '$_fullDirectory/$path';
    final data = await _client!.read(fullPath);
    return Uint8List.fromList(data);
  }

  @override
  Future<void> createDirectory(String path) async {
    await _ensureInitialized();

    final fullPath = '$_fullDirectory/$path';
    await _client!.mkdirAll(fullPath);
  }

  /// 获取备份文件名
  String getBackupFileName() {
    final type = PlatformUtils.isDesktop ? 'desktop' : 'phone';
    return 'piliplus_settings_$type.json';
  }
}
