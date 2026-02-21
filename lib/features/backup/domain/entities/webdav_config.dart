/// WebDAV 配置实体
class WebDavConfig {
  final String uri;
  final String username;
  final String password;
  final String directory;

  const WebDavConfig({
    required this.uri,
    required this.username,
    required this.password,
    required this.directory,
  });

  const WebDavConfig.empty()
    : uri = '',
      username = '',
      password = '',
      directory = '';

  WebDavConfig copyWith({
    String? uri,
    String? username,
    String? password,
    String? directory,
  }) {
    return WebDavConfig(
      uri: uri ?? this.uri,
      username: username ?? this.username,
      password: password ?? this.password,
      directory: directory ?? this.directory,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebDavConfig &&
          runtimeType == other.runtimeType &&
          uri == other.uri &&
          username == other.username &&
          password == other.password &&
          directory == other.directory;

  @override
  int get hashCode =>
      uri.hashCode ^ username.hashCode ^ password.hashCode ^ directory.hashCode;
}
