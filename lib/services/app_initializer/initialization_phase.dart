/// 应用初始化阶段
enum InitializationPhase {
  /// 阻塞阶段 - runApp 前必须完成
  blocking,

  /// 核心阶段 - runApp 后异步执行
  core,

  /// 辅助阶段 - 按需懒加载
  auxiliary,
}
