import 'package:sqlite3/sqlite3.dart';

/// 基础数据访问对象 (DAO)
///
/// 提供通用的数据库操作方法
abstract base class BaseDao {
  /// 数据库实例
  Database get db;

  /// 表名
  String get tableName;

  /// 创建表
  void createTable();

  /// 插入数据
  ///
  /// [values] 要插入的键值对
  /// 返回插入的行 ID
  int insert(Map<String, dynamic> values) {
    final columns = values.keys.join(', ');
    final placeholders = List.filled(values.length, '?').join(', ');
    final args = values.values.toList();

    db.execute(
      'INSERT INTO $tableName ($columns) VALUES ($placeholders)',
      args,
    );

    return db.lastInsertRowId;
  }

  /// 批量插入数据
  ///
  /// [valuesList] 要插入的数据列表
  /// 返回插入的行 ID 列表
  List<int> insertBatch(List<Map<String, dynamic>> valuesList) {
    final rowIds = <int>[];

    // 手动实现事务
    db.execute('BEGIN TRANSACTION');
    try {
      for (final values in valuesList) {
        final columns = values.keys.join(', ');
        final placeholders = List.filled(values.length, '?').join(', ');
        final args = values.values.toList();

        db.execute(
          'INSERT INTO $tableName ($columns) VALUES ($placeholders)',
          args,
        );
        rowIds.add(db.lastInsertRowId);
      }
      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }

    return rowIds;
  }

  /// 更新数据
  ///
  /// [values] 要更新的键值对
  /// [where] WHERE 子句
  /// [whereArgs] WHERE 子句的参数
  /// 返回影响的行数
  int update(
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  }) {
    final setClause = values.keys.map((key) => '$key = ?').join(', ');
    final args = [
      ...values.values,
      if (whereArgs != null) ...whereArgs,
    ];

    final sql = 'UPDATE $tableName SET $setClause';
    final query = where != null ? '$sql WHERE $where' : sql;

    db.execute(query, args);
    // 使用 SELECT changes() 获取影响的行数
    final result = db.select('SELECT changes() as count');
    return result.first['count'] as int;
  }

  /// 删除数据
  ///
  /// [where] WHERE 子句
  /// [whereArgs] WHERE 子句的参数
  /// 返回影响的行数
  int delete({
    String? where,
    List<Object?>? whereArgs,
  }) {
    final sql = 'DELETE FROM $tableName';
    final query = where != null ? '$sql WHERE $where' : sql;

    if (where != null && whereArgs != null) {
      db.execute(query, whereArgs);
    } else {
      db.execute(query);
    }
    // 使用 SELECT changes() 获取影响的行数
    final result = db.select('SELECT changes() as count');
    return result.first['count'] as int;
  }

  /// 查询数据
  ///
  /// [columns] 要查询的列，null 表示查询所有列
  /// [where] WHERE 子句
  /// [whereArgs] WHERE 子句的参数
  /// [groupBy] GROUP BY 子句
  /// [having] HAVING 子句
  /// [orderBy] ORDER BY 子句
  /// [limit] 限制返回的行数
  /// [offset] 偏移量
  /// 返回查询结果列表
  List<Map<String, dynamic>> query({
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) {
    final columnsStr = columns?.join(', ') ?? '*';
    var sql = 'SELECT $columnsStr FROM $tableName';

    final args = <Object?>[];

    if (where != null) {
      sql += ' WHERE $where';
      if (whereArgs != null) {
        args.addAll(whereArgs);
      }
    }

    if (groupBy != null) {
      sql += ' GROUP BY $groupBy';
    }

    if (having != null) {
      sql += ' HAVING $having';
    }

    if (orderBy != null) {
      sql += ' ORDER BY $orderBy';
    }

    if (limit != null) {
      sql += ' LIMIT $limit';
    }

    if (offset != null) {
      sql += ' OFFSET $offset';
    }

    final resultSet = args.isEmpty ? db.select(sql) : db.select(sql, args);
    return resultSet.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  /// 查询单条数据
  ///
  /// [columns] 要查询的列，null 表示查询所有列
  /// [where] WHERE 子句
  /// [whereArgs] WHERE 子句的参数
  /// [orderBy] ORDER BY 子句
  /// 返回查询结果，如果没有找到则返回 null
  Map<String, dynamic>? queryOne({
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
  }) {
    final results = query(
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: 1,
    );

    return results.isNotEmpty ? results.first : null;
  }

  /// 统计行数
  ///
  /// [where] WHERE 子句
  /// [whereArgs] WHERE 子句的参数
  /// 返回符合条件的行数
  int count({
    String? where,
    List<Object?>? whereArgs,
  }) {
    final sql = 'SELECT COUNT(*) as count FROM $tableName';
    final query = where != null ? '$sql WHERE $where' : sql;

    final resultSet =
        whereArgs != null ? db.select(query, whereArgs) : db.select(query);
    return resultSet.first['count'] as int;
  }

  /// 检查数据是否存在
  ///
  /// [where] WHERE 子句
  /// [whereArgs] WHERE 子句的参数
  /// 返回是否存在
  bool exists({
    String? where,
    List<Object?>? whereArgs,
  }) {
    return count(where: where, whereArgs: whereArgs) > 0;
  }

  /// 清空表
  void clear() {
    db.execute('DELETE FROM $tableName');
  }

  /// 删除表中所有数据并重置自增 ID
  void reset() {
    db.execute('DELETE FROM $tableName');
    db.execute('DELETE FROM sqlite_sequence WHERE name = ?', [tableName]);
  }

  /// 执行原始 SQL
  ///
  /// [sql] SQL 语句
  /// [args] 参数
  /// 返回影响的行数
  int execute(String sql, [List<Object?>? args]) {
    if (args != null) {
      db.execute(sql, args);
    } else {
      db.execute(sql);
    }
    // 使用 SELECT changes() 获取影响的行数
    final result = db.select('SELECT changes() as count');
    return result.first['count'] as int;
  }

  /// 执行原始查询
  ///
  /// [sql] SQL 语句
  /// [args] 参数
  /// 返回查询结果列表
  List<Map<String, dynamic>> rawQuery(String sql, [List<Object?>? args]) {
    final resultSet = args != null ? db.select(sql, args) : db.select(sql);
    return resultSet.map((row) => Map<String, dynamic>.from(row)).toList();
  }
}
