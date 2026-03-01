# 干净架构迁移规范

本文档说明如何将现有功能模块迁移到干净架构。

## 迁移原则

1. **YAGNI** - 只迁移需要的功能，不添加新功能
2. **小步提交** - 每个小步骤都要提交
3. **保持功能** - 迁移期间功能必须可用
4. **测试先行** - 先写测试再改代码

## 标准模块结构

\`\`\`
lib/features/{feature_name}/
├── domain/                      # 领域层（无外部依赖）
│   ├── entities/               # 实体类
│   ├── repositories/           # 仓库接口
│   └── usecases/              # 用例
├── data/                       # 数据层（实现仓库接口）
│   ├── datasources/           # 数据源
│   ├── models/                # 数据模型
│   ├── repositories/          # 仓库实现
│   └── mappers/               # 实体转换
├── presentation/              # 表现层（UI + 状态）
│   ├── providers/            # Riverpod providers
│   ├── pages/                # 页面
│   └── widgets/              # 组件
└── README.md                 # 模块文档
\`\`\`

## 迁移步骤

### 第一步：创建目录结构

使用脚手架脚本：

\`\`\`bash
./scripts/create_clean_architecture_feature.sh <feature_name>
\`\`\`

### 第二步：迁移 Domain 层

1. **创建实体类** - 从现有 Model 提取纯业务对象
2. **定义仓库接口** - 声明数据操作契约
3. **实现用例** - 封装业务逻辑

示例：

\`\`\`dart
// domain/entities/user_entity.dart
class UserEntity {
  final String id;
  final String name;
  const UserEntity({required this.id, required this.name});
}

// domain/repositories/user_repository.dart
abstract class UserRepository {
  Future<UserEntity> getUser(String id);
}

// domain/usecases/get_user.dart
class GetUserUseCase {
  final UserRepository _repository;
  GetUserUseCase(this._repository);
  Future<UserEntity> call(String id) => _repository.getUser(id);
}
\`\`\`

### 第三步：迁移 Data 层

1. **创建数据源** - 封装 API 调用
2. **创建模型类** - DTO 对象
3. **实现仓库** - 实现仓库接口
4. **创建 Mapper** - Model ↔ Entity 转换

示例：

\`\`\`dart
// data/datasources/user_remote_datasource.dart
class UserRemoteDatasource {
  final ApiClient _api;
  Future<UserModel> getUser(String id) => _api.get('/user/$id');
}

// data/repositories/user_repository_impl.dart
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDatasource _datasource;
  @override
  Future<UserEntity> getUser(String id) async {
    final model = await _datasource.getUser(id);
    return UserMapper.toEntity(model);
  }
}
\`\`\`

### 第四步：迁移 Presentation 层

1. **创建 Provider** - 使用 `@riverpod` 注解
2. **创建 Controller** - 继承 `AsyncNotifier` 或 `Notifier`
3. **更新页面** - 使用 `ConsumerWidget`
4. **删除旧代码** - 移除 GetX 相关代码

示例：

\`\`\`dart
// presentation/providers/user_providers.dart
@riverpod
UserRepository userRepository(UserRepositoryRef ref) {
  return UserRepositoryImpl(UserRemoteDatasource(ref.watch(apiProvider)));
}

@riverpod
class UserController extends _$UserController {
  @override
  Future<UserEntity> build(String id) async {
    return await ref.read(getUserUseCaseProvider)(id);
  }
}
\`\`\`

### 第五步：验证和测试

1. 运行 \`flutter analyze\`
2. 运行 \`dart format .\`
3. 运行功能测试
4. 使用 \`docs/MIGRATION_CHECKLIST.md\` 验证

## Riverpod 最佳实践

### Provider 类型

- **`@riverpod`** - 自动推导类型
- **`@Riverpod(<T>)`** - 指定返回类型

### Controller 基类

- **`Notifier<T>`** - 同步状态
- **`AsyncNotifier<T>`** - 异步状态
- **`StreamNotifier<T>`** - 流式状态

### 依赖注入

\`\`\`dart
// 通过 watch 自动重建
final value = ref.watch(provider);

// 通过 read 读取（不监听）
final controller = ref.read(provider.notifier);

// 通过 invalidate 刷新
ref.invalidate(provider);
\`\`\`

## 错误处理模式

### 模式 1: 直接抛出 Failure

\`\`\`dart
Future<T> call() async {
  try {
    return await repository.getData();
  } on ServerException catch (e) {
    throw ServerFailure(e.message);
  }
}
\`\`\`

### 模式 2: Either 类型

\`\`\`dart
Future<Either<Failure, T>> call() async {
  try {
    final result = await repository.getData();
    return Either.right(result);
  } catch (e) {
    return Either.left(ServerFailure(e.toString()));
  }
}
\`\`\`

## 常见问题

### Q: 如何处理现有 GetX 状态？

A: 可以并行存在，逐步替换。新代码使用 Riverpod，旧代码保持 GetX，通过适配层交互。

### Q: 如何处理复杂的表单验证？

A: 在 UseCase 层实现验证逻辑，返回 `Either<ValidationFailure, T>`。

### Q: 如何处理本地存储？

A: 创建 LocalDatasource，与 RemoteDatasource 并列，Repository 决定使用哪个。

## 参考

- [干净架构原则](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Riverpod 官方文档](https://riverpod.dev/)
- [视频模块示例](../lib/features/video/README.md)
