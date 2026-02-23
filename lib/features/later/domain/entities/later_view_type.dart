/// 稍后再看查看类型
enum LaterViewType {
  /// 全部
  all(0, '全部'),

  /// 未看完
  unfinished(2, '未看完')
  ;

  final int type;
  final String title;

  const LaterViewType(this.type, this.title);
}
