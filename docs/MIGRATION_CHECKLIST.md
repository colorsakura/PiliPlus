# 干净架构迁移检查清单

每个功能模块迁移完成后，使用此清单验证质量。

## 架构合规性

### Domain 层
- [ ] 实体类（Entities）无外部依赖
- [ ] 仓库接口（Repositories）在 Domain 层定义
- [ ] 用例（UseCases）只依赖仓库接口
- [ ] 无导入 `package:PiliPlus/data` 或 `presentation`
- [ ] 无导入 GetX 相关包

### Data 层
- [ ] 实现 Domain 层定义的仓库接口
- [ ] 数据源（DataSources）正确处理异常
- [ ] 模型（Models）与实体（Entities）分离
- [ ] Mapper 正确转换 Model ↔ Entity
- [ ] 网络错误转换为 ServerException 或 NetworkException

### Presentation 层
- [ ] 只通过 UseCase 调用业务逻辑
- [ ] 不直接访问 Data 层
- [ ] 使用 Riverpod 管理状态
- [ ] Provider 使用 `@riverpod` 注解
- [ ] Controller/Notifier 继承正确的基类

## 代码质量

### 静态分析
- [ ] `flutter analyze` 无错误
- [ ] `dart format .` 格式化通过
- [ ] 无警告信息（或警告已确认可忽略）

### 依赖管理
- [ ] 无未使用的导入
- [ ] 无循环依赖
- [ ] 依赖方向正确（外层依赖内层）

### 错误处理
- [ ] 所有异步操作有错误处理
- [ ] 使用 Either<Failure, T> 或 try-catch
- [ ] 用户友好的错误提示

## 功能完整性

### 功能测试
- [ ] 主流程功能正常
- [ ] 边界情况处理正确
- [ ] 加载状态显示正确
- [ ] 错误状态显示正确

### 性能
- [ ] 无明显性能回退
- [ ] 列表滚动流畅
- [ ] 页面切换流畅

## 文档

- [ ] 模块 README 已更新
- [ ] 公共 API 有文档注释
- [ ] 复杂逻辑有注释说明

## 迁移标记

- [ ] 旧 GetX Controller 标记为 `@Deprecated`
- [ ] 旧视图文件标记为 `@Deprecated`
- [ ] 路由更新到新页面
- [ ] 删除旧代码（确认新代码稳定后）

---

## 使用方法

1. 迁移模块时，逐项检查
2. 完成后提交到 Git
3. 在模块 README 中记录迁移状态
