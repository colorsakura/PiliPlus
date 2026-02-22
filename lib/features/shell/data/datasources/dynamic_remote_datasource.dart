import 'package:PiliPlus/grpc/dyn.dart';

/// 动态远程数据源
class DynamicRemoteDataSource {
  /// 获取未读动态数量
  Future<int?> getDynRed() => DynGrpc.dynRed();
}
