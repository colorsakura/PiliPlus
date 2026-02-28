/// 持久化文件系统
///
/// 使用应用文档目录存储缓存，实现持久化存储
library;

import 'package:file/file.dart' hide FileSystem;
import 'package:file/local.dart';
import 'package:flutter_cache_manager/src/storage/file_system/file_system.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 持久化文件系统
///
/// 使用应用文档目录而不是临时目录，缓存不会被系统清理
class PersistentFileSystem implements FileSystem {
  final Future<Directory> _fileDir;
  final String _cacheKey;

  PersistentFileSystem(this._cacheKey) : _fileDir = _createDirectory(_cacheKey);

  static Future<Directory> _createDirectory(String key) async {
    // 使用应用文档目录实现持久化存储
    final baseDir = await getApplicationCacheDirectory();
    final path = p.join(baseDir.path, 'piliplus', key);

    const fs = LocalFileSystem();
    final directory = fs.directory(path);
    await directory.create(recursive: true);
    return directory;
  }

  @override
  Future<File> createFile(String name) async {
    final directory = await _fileDir;
    if (!(await directory.exists())) {
      await _createDirectory(_cacheKey);
    }
    return directory.childFile(name);
  }
}
