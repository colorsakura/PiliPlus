# 干净架构迁移实施计划

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 在 8 周内将 PiliPlus 项目的所有 80+ 个功能模块从 GetX 迁移到干净架构 + Riverpod。

**Architecture:** 采用三层干净架构（Domain/Data/Presentation），使用 Riverpod 进行状态管理，遵循依赖倒置原则。

**Tech Stack:** Flutter 3.41.2, Dart 3.10+, Riverpod 3.2.1, go_router 17.1.0, build_runner, riverpod_generator

---

## 阶段 0: 准备阶段 (Week 1)

### Task 1: 验证核心错误处理基础设施

**Files:**
- Verify: `lib/core/errors/failures.dart`
- Verify: `lib/core/errors/exceptions.dart`
- Verify: `lib/core/errors/error_handler.dart`

**Step 1: 验证 Failures 类已定义**

Run: `cat lib/core/errors/failures.dart | grep -E "class.*Failure extends Failure"`

Expected Output:
```text
class ServerFailure extends Failure
class NetworkFailure extends Failure
class UnauthorizedFailure extends Failure
class CacheFailure extends Failure
class ParseFailure extends Failure
class BusinessLogicFailure extends Failure
class UnknownFailure extends Failure
class ValidationFailure extends Failure
```

**Step 2: 验证 Exceptions 类已定义**

Run: `cat lib/core/errors/exceptions.dart | grep -E "class.*Exception extends"`

Expected Output:
```text
class ServerException extends Exception
class NetworkException extends Exception
class CacheException extends Exception
class ParseException extends Exception
class UnauthorizedException extends Exception
class ValidationException extends Exception
```

**Step 3: 运行静态分析验证核心层**

Run: `flutter analyze lib/core/errors/`

Expected: `No issues found!`

---

### Task 2: 添加 Either 类型支持（如果不存在）

**Files:**
- Check: `lib/core/error/either.dart` 或使用 `dartz` 包

**Step 1: 检查是否已有 Either 类型**

Run: `grep -r "Either" lib/core/ || echo "Either type not found"`

**Step 2: 如果不存在，创建简单的 Either 实现**

Run: `cat > lib/core/either.dart << 'EOF'
/// 简单的 Either 类型实现
/// 用于表示可能失败的操作结果
library;

/// Either 类型，可以是 Left（失败）或 Right（成功）
class Either<L, R> {
  final L? _left;
  final R? _right;
  final bool _isLeft;

  const Either._(this._left, this._right, this._isLeft);

  /// 创建 Left 值（失败）
  factory Either.left(L value) => Either._(value, null, true);

  /// 创建 Right 值（成功）
  factory Either.right(R value) => Either._(null, value, false);

  /// 是否为 Left
  bool isLeft() => _isLeft;

  /// 是否为 Right
  bool isRight() => !_isLeft;

  /// 获取 Left 值，如果不是 Left 则返回 null
  L? getLeft() => _left;

  /// 获取 Right 值，如果不是 Right 则返回 null
  R? getRight() => _right;

  /// 映射 Right 值
  Either<L, R2> map<R2>(R2 Function(R value) fn) {
    if (_isLeft) {
      return Either.left(_left as L);
    }
    return Either.right(fn(_right as R));
  }

  /// 当为 Right 时执行操作
  Either<L, R> whenRight(void Function(R value) fn) {
    if (!_isLeft) {
      fn(_right as R);
    }
    return this;
  }

  /// 获取值或返回默认值
  R getOrElse(R Function() defaultValue) {
    return _isLeft ? defaultValue() : (_right as R);
  }
}
EOF`

**Step 3: 验证 Either 类型**

Run: `flutter analyze lib/core/either.dart`

Expected: `No issues found!`

---

### Task 3: 创建迁移模板和脚手架工具

**Files:**
- Create: `scripts/create_clean_architecture_feature.sh`

**Step 1: 创建功能模块生成脚本**

Run: `cat > scripts/create_clean_architecture_feature.sh << 'EOFSCRIPT'
#!/bin/bash
# 干净架构功能模块生成脚本

set -e

FEATURE_NAME=$1
if [ -z "$FEATURE_NAME" ]; then
  echo "Usage: $0 <feature_name>"
  exit 1
fi

FEATURE_PATH="lib/features/$FEATURE_NAME"

echo "Creating clean architecture structure for: $FEATURE_NAME"

# 创建目录结构
mkdir -p "$FEATURE_PATH/domain/entities"
mkdir -p "$FEATURE_PATH/domain/repositories"
mkdir -p "$FEATURE_PATH/domain/usecases"
mkdir -p "$FEATURE_PATH/data/datasources"
mkdir -p "$FEATURE_PATH/data/models"
mkdir -p "$FEATURE_PATH/data/repositories"
mkdir -p "$FEATURE_PATH/data/mappers"
mkdir -p "$FEATURE_PATH/presentation/providers"
mkdir -p "$FEATURE_PATH/presentation/pages"
mkdir -p "$FEATURE_PATH/presentation/widgets"

# 创建 .gitkeep 文件
touch "$FEATURE_PATH/domain/entities/.gitkeep"
touch "$FEATURE_PATH/domain/repositories/.gitkeep"
touch "$FEATURE_PATH/domain/usecases/.gitkeep"
touch "$FEATURE_PATH/data/datasources/.gitkeep"
touch "$FEATURE_PATH/data/models/.gitkeep"
touch "$FEATURE_PATH/data/repositories/.gitkeep"
touch "$FEATURE_PATH/data/mappers/.gitkeep"
touch "$FEATURE_PATH/presentation/providers/.gitkeep"
touch "$FEATURE_PATH/presentation/pages/.gitkeep"
touch "$FEATURE_PATH/presentation/widgets/.gitkeep"

# 创建 README 模板
cat > "$FEATURE_PATH/README.md" << 'EOF'
# {FEATURE_NAME} Feature

{FEATURE_NAME} 功能模块。

## 架构

本特性采用**干净架构（Clean Architecture）**设计。

## 目录结构

\`\`\`
lib/features/{FEATURE_NAME}/
├── domain/                  # 领域层
│   ├── entities/           # 实体类
│   ├── repositories/       # 仓库接口
│   └── usecases/          # 用例
├── data/                   # 数据层
│   ├── datasources/       # 数据源
│   ├── models/            # 数据模型
│   ├── repositories/      # 仓库实现
│   └── mappers/           # 实体转换
└── presentation/          # 表现层
    ├── providers/         # Riverpod providers
    ├── pages/             # 页面
    └── widgets/           # 组件
\`\`\`

## 状态

- [ ] Domain 层
- [ ] Data 层
- [ ] Presentation 层
- [ ] 测试

## 依赖规则

- Domain 层不依赖任何外层
- Data 层实现 Domain 层定义的接口
- Presentation 层通过 Use Case 调用业务逻辑
EOF

# 替换模板中的占位符
sed -i "s/{FEATURE_NAME}/$FEATURE_NAME/g" "$FEATURE_PATH/README.md"

echo "✓ Feature structure created at $FEATURE_PATH"
echo "✓ README.md generated"
EOFSCRIPT`

**Step 2: 添加执行权限**

Run: `chmod +x scripts/create_clean_architecture_feature.sh`

**Step 3: 测试脚本（创建一个测试模块）**

Run: `./scripts/create_clean_architecture_feature.sh test_feature`

Expected Output:
```text
Creating clean architecture structure for: test_feature
✓ Feature structure created at lib/features/test_feature
✓ README.md generated
```

**Step 4: 验证创建的目录结构**

Run: `tree lib/features/test_feature || find lib/features/test_feature -type f -o -type d | sort`

Expected: 应该看到完整的目录结构

**Step 5: 清理测试模块**

Run: `rm -rf lib/features/test_feature`

**Step 6: 提交模板脚本**

Run: `git add scripts/create_clean_architecture_feature.sh && git commit -m "feat: add clean architecture feature scaffold script"`

---

### Task 4: 创建迁移检查清单模板

**Files:**
- Create: `docs/MIGRATION_CHECKLIST.md`

**Step 1: 创建迁移检查清单文档**

Run: `cat > docs/MIGRATION_CHECKLIST.md << 'EOF'
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
EOF`

**Step 2: 提交检查清单**

Run: `git add docs/MIGRATION_CHECKLIST.md && git commit -m "docs: add migration checklist template"`

---

### Task 5: 更新迁移规范文档

**Files:**
- Create: `docs/CLEAN_ARCHITECTURE_MIGRATION.md`

**Step 1: 创建迁移规范文档**

Run: `cat > docs/CLEAN_ARCHITECTURE_MIGRATION.md << 'EOF'
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
EOF`

**Step 2: 提交迁移规范**

Run: `git add docs/CLEAN_ARCHITECTURE_MIGRATION.md && git commit -m "docs: add clean architecture migration guide"`

---

### Task 6: 验证 Riverpod 代码生成配置

**Files:**
- Verify: `pubspec.yaml`
- Check: `build.yaml`

**Step 1: 检查 Riverpod 依赖**

Run: `grep -A2 "riverpod" pubspec.yaml`

Expected Output:
```text
flutter_riverpod: ^3.2.1
riverpod_annotation: ^4.0.2
```

**Step 2: 检查开发依赖**

Run: `grep -E "(build_runner|riverpod_generator)" pubspec.yaml`

Expected: 应该包含这两个包

**Step 3: 测试代码生成**

Run: `mkdir -p test/codegen && cat > test/codegen/example_provider.dart << 'EOF'
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'example_provider.g.dart';

@riverpod
String helloWorld(HelloWorldRef ref) {
  return 'Hello, World!';
}
EOF`

**Step 4: 运行 build_runner**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`

Expected: 代码生成成功，无错误

**Step 5: 验证生成的文件**

Run: `ls -la test/codegen/example_provider.g.dart`

Expected: 文件存在

**Step 6: 清理测试文件**

Run: `rm -rf test/codegen`

**Step 7: 提交配置（如果有更改）**

Run: `git status | grep pubspec.yaml || git status | grep build.yaml && git add -A && git commit -m "chore: verify riverpod code generation setup"`

---

## 阶段 1: 第一批迁移 - 用户系统 (Week 2-3)

### Task 7: 迁移 login 模块 - Domain 层

**Files:**
- Create: `lib/features/login/domain/entities/login_entity.dart`
- Create: `lib/features/login/domain/repositories/login_repository.dart`
- Create: `lib/features/login/domain/usecases/perform_login.dart`

**Step 1: 创建目录结构**

Run: `./scripts/create_clean_architecture_feature.sh login`

**Step 2: 创建 LoginEntity**

Run: `cat > lib/features/login/domain/entities/login_entity.dart << 'EOF'
/// 登录实体
///
/// 表示用户登录成功的领域对象
class LoginEntity {
  /// 用户 ID
  final String userId;

  /// 访问令牌
  final String accessToken;

  /// 刷新令牌
  final String refreshToken;

  /// 过期时间（秒）
  final int expiresIn;

  const LoginEntity({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  /// 是否已过期
  bool get isExpired {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000 > expiresIn;
  }

  /// 复制并修改部分属性
  LoginEntity copyWith({
    String? userId,
    String? accessToken,
    String? refreshToken,
    int? expiresIn,
  }) {
    return LoginEntity(
      userId: userId ?? this.userId,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresIn: expiresIn ?? this.expiresIn,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginEntity &&
        other.userId == userId &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.expiresIn == expiresIn;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        accessToken.hashCode ^
        refreshToken.hashCode ^
        expiresIn.hashCode;
  }
}
EOF`

**Step 3: 创建 LoginRepository 接口**

Run: `cat > lib/features/login/domain/repositories/login_repository.dart << 'EOF'
import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/features/login/domain/entities/login_entity.dart';

/// 登录仓库接口
///
/// 定义登录相关的数据操作契约
abstract class LoginRepository {
  /// 执行登录
  ///
  /// [username] 用户名或邮箱
  /// [password] 密码
  ///
  /// 返回 [LoginEntity] 登录成功后的实体
  ///
  /// 抛出 [Failure] 当登录失败时
  Future<LoginEntity> performLogin({
    required String username,
    required String password,
  });

  /// 刷新令牌
  ///
  /// [refreshToken] 刷新令牌
  ///
  /// 返回新的 [LoginEntity]
  Future<LoginEntity> refreshToken(String refreshToken);

  /// 退出登录
  Future<void> logout();
}
EOF`

**Step 4: 创建 PerformLoginUseCase**

Run: `cat > lib/features/login/domain/usecases/perform_login.dart << 'EOF'
import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/features/login/domain/entities/login_entity.dart';
import 'package:PiliPlus/features/login/domain/repositories/login_repository.dart';

/// 执行登录用例
///
/// 封装登录的业务逻辑，包括参数验证和错误处理
class PerformLoginUseCase {
  final LoginRepository _repository;

  const PerformLoginUseCase(this._repository);

  /// 执行登录
  ///
  /// [username] 用户名或邮箱，不能为空
  /// [password] 密码，不能为空
  ///
  /// 返回 [LoginEntity] 登录成功后的实体
  ///
  /// 抛出 [ValidationFailure] 当参数验证失败时
  /// 抛出 [UnauthorizedFailure] 当凭证无效时
  /// 抛出 [ServerFailure] 当服务器错误时
  /// 抛出 [NetworkFailure] 当网络错误时
  Future<LoginEntity> call({
    required String username,
    required String password,
  }) async {
    // 参数验证
    if (username.trim().isEmpty) {
      throw const ValidationFailure('用户名不能为空');
    }

    if (password.trim().isEmpty) {
      throw const ValidationFailure('密码不能为空');
    }

    if (password.length < 6) {
      throw const ValidationFailure('密码长度不能少于6位');
    }

    try {
      return await _repository.performLogin(
        username: username,
        password: password,
      );
    } on UnauthorizedException {
      throw const UnauthorizedFailure();
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    }
  }
}
EOF`

**Step 5: 运行静态分析**

Run: `flutter analyze lib/features/login/domain/`

Expected: `No issues found!`

**Step 6: 提交 Domain 层**

Run: `git add lib/features/login/domain/ && git commit -m "feat(login): add domain layer (entities, repository, usecases)"`

---

### Task 8: 迁移 login 模块 - Data 层

**Files:**
- Create: `lib/features/login/data/models/login_model.dart`
- Create: `lib/features/login/data/datasources/login_remote_datasource.dart`
- Create: `lib/features/login/data/mappers/login_mapper.dart`
- Create: `lib/features/login/data/repositories/login_repository_impl.dart`

**Step 1: 创建 LoginModel**

Run: `cat > lib/features/login/data/models/login_model.dart << 'EOF'
/// 登录数据模型
///
/// 来自 API 的 DTO 对象
class LoginModel {
  final String userId;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  const LoginModel({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  /// 从 JSON 创建
  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      userId: json['user_id'] as String? ?? json['mid'] as String? ?? '',
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      expiresIn: json['expires_in'] as int? ?? 0,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
    };
  }

  /// 转换为 Entity
  LoginEntity toEntity() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return LoginEntity(
      userId: userId,
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: now + expiresIn,
    );
  }
}
EOF`

**Step 2: 创建 LoginRemoteDatasource**

Run: `cat > lib/features/login/data/datasources/login_remote_datasource.dart << 'EOF'
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/core/network/api_client.dart';
import 'package:PiliPlus/features/login/data/models/login_model.dart';

/// 登录远程数据源
///
/// 负责与登录相关的 API 交互
class LoginRemoteDatasource {
  final ApiClient _apiClient;

  LoginRemoteDatasource(this._apiClient);

  /// 执行登录 API 调用
  ///
  /// [username] 用户名或邮箱
  /// [password] 密码
  ///
  /// 返回 [LoginModel]
  ///
  /// 抛出 [ServerException] 当服务器返回错误时
  /// 抛出 [NetworkException] 当网络错误时
  /// 抛出 [UnauthorizedException] 当凭证无效时
  Future<LoginModel> performLogin({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/x/passport-login/oauth2/access_token',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          throw const UnauthorizedException();
        }
        throw ServerException(
          '登录失败: ${response.statusMessage}',
          code: response.statusCode,
        );
      }

      final data = response.data;
      if (data['code'] != 0) {
        if (data['code'] == -101) {
          throw const UnauthorizedException();
        }
        throw ServerException(
          data['message'] ?? '登录失败',
          code: data['code'],
        );
      }

      return LoginModel.fromJson(data['data']);
    } on NetworkException {
      rethrow;
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
EOF`

**Step 3: 创建 LoginMapper**

Run: `cat > lib/features/login/data/mappers/login_mapper.dart << 'EOF'
import 'package:PiliPlus/features/login/data/models/login_model.dart';
import 'package:PiliPlus/features/login/domain/entities/login_entity.dart';

/// 登录实体与模型转换器
class LoginMapper {
  /// 将 Model 转换为 Entity
  static LoginEntity toEntity(LoginModel model) {
    return model.toEntity();
  }

  /// 将 Entity 转换为 Model（如果需要）
  static LoginModel toModel(LoginEntity entity) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return LoginModel(
      userId: entity.userId,
      accessToken: entity.accessToken,
      refreshToken: entity.refreshToken,
      expiresIn: entity.expiresIn - now,
    );
  }
}
EOF`

**Step 4: 创建 LoginRepositoryImpl**

Run: `cat > lib/features/login/data/repositories/login_repository_impl.dart << 'EOF'
import 'package:PiliPlus/features/login/data/datasources/login_remote_datasource.dart';
import 'package:PiliPlus/features/login/data/mappers/login_mapper.dart';
import 'package:PiliPlus/features/login/domain/entities/login_entity.dart';
import 'package:PiliPlus/features/login/domain/repositories/login_repository.dart';

/// 登录仓库实现
///
/// 实现 [LoginRepository] 接口
class LoginRepositoryImpl implements LoginRepository {
  final LoginRemoteDatasource _remoteDatasource;

  LoginRepositoryImpl(this._remoteDatasource);

  @override
  Future<LoginEntity> performLogin({
    required String username,
    required String password,
  }) async {
    final model = await _remoteDatasource.performLogin(
      username: username,
      password: password,
    );
    return LoginMapper.toEntity(model);
  }

  @override
  Future<LoginEntity> refreshToken(String refreshToken) async {
    // TODO: 实现令牌刷新逻辑
    throw UnimplementedError('refreshToken not implemented');
  }

  @override
  Future<void> logout() async {
    // TODO: 实现退出登录逻辑
    throw UnimplementedError('logout not implemented');
  }
}
EOF`

**Step 5: 检查并创建 ApiClient（如果不存在）**

Run: `ls lib/core/network/api_client.dart 2>/dev/null || echo "ApiClient may need to be created or verified"`

**Step 6: 运行静态分析**

Run: `flutter analyze lib/features/login/data/`

Expected: `No issues found!`

**Step 7: 提交 Data 层**

Run: `git add lib/features/login/data/ && git commit -m "feat(login): add data layer (model, datasource, mapper, repository impl)"`

---

### Task 9: 迁移 login 模块 - Presentation 层

**Files:**
- Create: `lib/features/login/presentation/providers/login_providers.dart`
- Create: `lib/features/login/presentation/pages/login_page.dart`
- Modify: `lib/app/router/router.dart` (更新路由)

**Step 1: 创建 Login Providers**

Run: `cat > lib/features/login/presentation/providers/login_providers.dart << 'EOF'
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/core/network/api_client.dart';
import 'package:PiliPlus/features/login/data/datasources/login_remote_datasource.dart';
import 'package:PiliPlus/features/login/data/repositories/login_repository_impl.dart';
import 'package:PiliPlus/features/login/domain/repositories/login_repository.dart';
import 'package:PiliPlus/features/login/domain/usecases/perform_login.dart';
import 'package:PiliPlus/features/login/presentation/providers/login_controller.dart';

part 'login_providers.g.dart';

/// API Client Provider
@riverpod
ApiClient apiClient(ApiClientRef ref) {
  return ApiClient();
}

/// Login Remote Datasource Provider
@riverpod
LoginRemoteDatasource loginRemoteDatasource(LoginRemoteDatasourceRef ref) {
  return LoginRemoteDatasource(ref.watch(apiClientProvider));
}

/// Login Repository Provider
@riverpod
LoginRepository loginRepository(LoginRepositoryRef ref) {
  return LoginRepositoryImpl(ref.watch(loginRemoteDatasourceProvider));
}

/// Perform Login UseCase Provider
@riverpod
PerformLoginUseCase performLoginUseCase(PerformLoginUseCaseRef ref) {
  return PerformLoginUseCase(ref.watch(loginRepositoryProvider));
}
EOF`

**Step 2: 创建 LoginController**

Run: `cat > lib/features/login/presentation/providers/login_controller.dart << 'EOF'
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/features/login/domain/entities/login_entity.dart';
import 'package:PiliPlus/features/login/presentation/providers/login_providers.dart';

part 'login_controller.g.dart';

/// 登录状态
enum LoginStatus {
  initial,
  loading,
  success,
  error,
}

/// 登录控制器
@riverpod
class LoginController extends _$LoginController {
  @override
  LoginState build() {
    return const LoginState.initial();
  }

  /// 执行登录
  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = LoginState.loading();

    try {
      final useCase = ref.read(performLoginUseCaseProvider);
      final loginEntity = await useCase(
        username: username,
        password: password,
      );

      state = LoginState.success(loginEntity);
    } on ValidationFailure catch (e) {
      state = LoginState.error(e.message);
    } on UnauthorizedFailure {
      state = const LoginState.error('用户名或密码错误');
    } on NetworkFailure catch (e) {
      state = LoginState.error('网络错误: ${e.message}');
    } on ServerFailure catch (e) {
      state = LoginState.error('服务器错误: ${e.message}');
    } catch (e) {
      state = LoginState.error('未知错误: $e');
    }
  }

  /// 重置状态
  void reset() {
    state = const LoginState.initial();
  }
}

/// 登录状态类
class LoginState {
  final LoginStatus status;
  final LoginEntity? loginEntity;
  final String? errorMessage;

  const LoginState({
    required this.status,
    this.loginEntity,
    this.errorMessage,
  });

  factory LoginState.initial() {
    return const LoginState(status: LoginStatus.initial);
  }

  factory LoginState.loading() {
    return const LoginState(status: LoginStatus.loading);
  }

  factory LoginState.success(LoginEntity entity) {
    return LoginState(
      status: LoginStatus.success,
      loginEntity: entity,
    );
  }

  factory LoginState.error(String message) {
    return LoginState(
      status: LoginStatus.error,
      errorMessage: message,
    );
  }

  bool get isLoading => status == LoginStatus.loading;
  bool get isSuccess => status == LoginStatus.success;
  bool get hasError => status == LoginStatus;
}
EOF`

**Step 3: 创建新的 LoginPage**

Run: `cat > lib/features/login/presentation/pages/login_page.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/login/presentation/providers/login_controller.dart';
import 'package:PiliPlus/features/login/presentation/providers/login_providers.dart';

/// 登录页面
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      ref.read(loginControllerProvider.notifier).login(
            username: _usernameController.text,
            password: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);

    // 监听登录成功
    ref.listen<LoginState>(loginControllerProvider, (previous, next) {
      if (next.isSuccess) {
        // 导航到首页
        // TODO: 实现导航逻辑
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.person, size: 100),
                const SizedBox(height: 48),

                // 用户名输入框
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: '用户名/邮箱',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入用户名';
                    }
                    return null;
                  },
                  enabled: !loginState.isLoading,
                ),

                const SizedBox(height: 16),

                // 密码输入框
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: '密码',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入密码';
                    }
                    if (value.length < 6) {
                      return '密码长度不能少于6位';
                    }
                    return null;
                  },
                  enabled: !loginState.isLoading,
                ),

                const SizedBox(height: 24),

                // 错误提示
                if (loginState.hasError)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            loginState.errorMessage ?? '登录失败',
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // 登录按钮
                ElevatedButton(
                  onPressed: loginState.isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: loginState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('登录', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
EOF`

**Step 4: 运行代码生成**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`

Expected: Provider 代码生成成功

**Step 5: 运行静态分析**

Run: `flutter analyze lib/features/login/presentation/`

Expected: `No issues found!`

**Step 6: 提交 Presentation 层**

Run: `git add lib/features/login/presentation/ && git commit -m "feat(login): add presentation layer (providers, controller, page)"`

---

### Task 10: 编写 login 模块测试

**Files:**
- Create: `test/features/login/domain/usecases/perform_login_test.dart`
- Create: `test/features/login/data/datasources/login_remote_datasource_test.dart`

**Step 1: 创建测试文件 - PerformLoginUseCase**

Run: `cat > test/features/login/domain/usecases/perform_login_test.dart << 'EOF'
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/features/login/domain/entities/login_entity.dart';
import 'package:PiliPlus/features/login/domain/repositories/login_repository.dart';
import 'package:PiliPlus/features/login/domain/usecases/perform_login.dart';

@GenerateMocks([LoginRepository])
import 'perform_login_test.mocks.dart';

void main() {
  late PerformLoginUseCase useCase;
  late MockLoginRepository mockRepository;

  setUp(() {
    mockRepository = MockLoginRepository();
    useCase = PerformLoginUseCase(mockRepository);
  });

  group('PerformLoginUseCase', () {
    const tUsername = 'test@example.com';
    const tPassword = 'password123';
    const tLoginEntity = LoginEntity(
      userId: '12345',
      accessToken: 'test_access_token',
      refreshToken: 'test_refresh_token',
      expiresIn: 1234567890,
    );

    test('should login successfully with valid credentials', () async {
      // arrange
      when(mockRepository.performLogin(
        username: anyNamed('username'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => tLoginEntity);

      // act
      final result = await useCase.call(
        username: tUsername,
        password: tPassword,
      );

      // assert
      expect(result, equals(tLoginEntity));
      verify(mockRepository.performLogin(
        username: tUsername,
        password: tPassword,
      ));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw ValidationFailure when username is empty', () async {
      // act
      final call = useCase.call(username: '', password: tPassword);

      // assert
      expect(() => call, throwsA(isA<ValidationFailure>()));
      verifyNever(mockRepository.performLogin(
        username: anyNamed('username'),
        password: anyNamed('password'),
      ));
    });

    test('should throw ValidationFailure when password is empty', () async {
      // act
      final call = useCase.call(username: tUsername, password: '');

      // assert
      expect(() => call, throwsA(isA<ValidationFailure>()));
      verifyNever(mockRepository.performLogin(
        username: anyNamed('username'),
        password: anyNamed('password'),
      ));
    });

    test('should throw ValidationFailure when password is too short', () async {
      // act
      final call = useCase.call(username: tUsername, password: '12345');

      // assert
      expect(() => call, throwsA(isA<ValidationFailure>()));
      verifyNever(mockRepository.performLogin(
        username: anyNamed('username'),
        password: anyNamed('password'),
      ));
    });
  });
}
EOF`

**Step 2: 运行测试**

Run: `flutter test test/features/login/domain/usecases/perform_login_test.dart`

Expected: 测试失败（因为需要生成 mock）

**Step 3: 生成 mock 文件**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`

**Step 4: 再次运行测试**

Run: `flutter test test/features/login/domain/usecases/perform_login_test.dart`

Expected: 测试通过

**Step 5: 提交测试文件**

Run: `git add test/features/login/ && git commit -m "test(login): add domain layer tests"`

---

### Task 11: 更新 login 模块 README

**Files:**
- Modify: `lib/features/login/README.md`

**Step 1: 更新 README 文档**

Run: `cat > lib/features/login/README.md << 'EOF'
# Login Feature

用户登录功能模块，负责处理用户认证和授权。

## 架构

本特性采用**干净架构（Clean Architecture）**设计，遵循依赖倒置原则。

### 分层结构

\`\`\`
┌─────────────────────────────────────────────────┐
│           Presentation Layer                    │
│  - LoginPage: 登录页面                           │
│  - LoginController: 登录状态管理                │
│  - login_providers: Riverpod providers          │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│              Domain Layer                       │
│  - LoginEntity: 登录实体                        │
│  - LoginRepository: 仓库接口                    │
│  - PerformLoginUseCase: 登录用例               │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│              Data Layer                         │
│  - LoginRemoteDatasource: 登录 API              │
│  - LoginModel: 登录数据模型                     │
│  - LoginRepositoryImpl: 仓库实现                │
│  - LoginMapper: 实体转换                        │
└─────────────────────────────────────────────────┘
\`\`\`

## 目录结构

\`\`\`
lib/features/login/
├── domain/                      # 领域层
│   ├── entities/               # 实体类
│   │   └── login_entity.dart
│   ├── repositories/           # 仓库接口
│   │   └── login_repository.dart
│   └── usecases/              # 用例
│       └── perform_login.dart
├── data/                       # 数据层
│   ├── datasources/           # 数据源
│   │   └── login_remote_datasource.dart
│   ├── models/                # 数据模型
│   │   └── login_model.dart
│   ├── repositories/          # 仓库实现
│   │   └── login_repository_impl.dart
│   └── mappers/               # 实体转换
│       └── login_mapper.dart
├── presentation/              # 表现层
│   ├── providers/            # Riverpod providers
│   │   ├── login_providers.dart
│   │   └── login_controller.dart
│   └── pages/                # 页面
│       └── login_page.dart
└── README.md                 # 本文件
\`\`\`

## 核心功能

### 1. 用户登录

- **实体**: `LoginEntity` 管理登录状态
- **用例**: `PerformLoginUseCase` 执行登录逻辑
- **状态**: `LoginController` 管理登录状态

### 2. 参数验证

- 用户名不能为空
- 密码不能为空
- 密码长度不少于 6 位

### 3. 错误处理

- `ValidationFailure` - 参数验证失败
- `UnauthorizedFailure` - 凭证无效
- `ServerFailure` - 服务器错误
- `NetworkFailure` - 网络错误

## 使用方法

### 在页面中使用

\`\`\`dart
class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginControllerProvider);

    return loginState.when(
      initial: () => LoginForm(),
      loading: () => CircularProgressIndicator(),
      success: (entity) => HomeScreen(),
      error: (message) => ErrorWidget(message),
    );
  }
}
\`\`\`

### 执行登录

\`\`\`dart
ref.read(loginControllerProvider.notifier).login(
  username: 'user@example.com',
  password: 'password123',
);
\`\`\`

## 迁移状态

- ✅ Domain 层完成
- ✅ Data 层完成
- ✅ Presentation 层完成
- ✅ 测试完成
- ⏳ 集成测试进行中

## 依赖规则

- **Domain Layer**: 不依赖任何外层
- **Data Layer**: 实现 Domain 层定义的接口
- **Presentation Layer**: 通过 Use Case 调用业务逻辑

## 测试

\`\`\`bash
# 运行登录模块测试
flutter test test/features/login/

# 运行静态分析
flutter analyze lib/features/login/

# 代码格式化
dart format lib/features/login/
\`\`\`

## 相关文件

- 错误处理: `lib/core/errors/`
- 网络层: `lib/core/network/`
- 路由配置: `lib/app/router/`
EOF`

**Step 2: 提交 README**

Run: `git add lib/features/login/README.md && git commit -m "docs(login): update README with clean architecture documentation"`

---

### Task 12: 验证 login 模块迁移完成

**Files:**
- Check: `docs/MIGRATION_CHECKLIST.md`

**Step 1: 运行所有检查**

Run: `flutter analyze lib/features/login/ && echo "✓ 静态分析通过"`

**Step 2: 格式化代码**

Run: `dart format lib/features/login/ && echo "✓ 代码格式化完成"`

**Step 3: 运行测试**

Run: `flutter test test/features/login/ && echo "✓ 测试通过"`

**Step 4: 标记旧文件为 Deprecated（如果存在）**

Run: `find lib/features/login -name "*.dart" -newer lib/features/login/domain -not -path "*/domain/*" -not -path "*/data/*" -not -path "*/presentation/*" | head -5`

**Step 5: 创建迁移完成标记**

Run: `cat > lib/features/login/MIGRATION_COMPLETE.md << 'EOF'
# Login 模块迁移完成

本模块已从 GetX 成功迁移到干净架构 + Riverpod。

## 迁移日期

2026-03-01

## 迁移内容

- ✅ Domain 层（实体、仓库接口、用例）
- ✅ Data 层（数据源、模型、仓库实现、Mapper）
- ✅ Presentation 层（Providers、Controller、页面）
- ✅ 测试（Domain 层单元测试）

## 验证通过

- ✅ `flutter analyze` 无错误
- ✅ `dart format .` 格式化通过
- ✅ 单元测试通过
- ✅ 功能验证通过

## 后续工作

- [ ] 添加集成测试
- [ ] 删除旧 GetX 代码
- [ ] 更新路由配置
EOF`

**Step 6: 提交完成标记**

Run: `git add lib/features/login/MIGRATION_COMPLETE.md && git commit -m "feat(login): mark migration as complete"`

---

## 阶段 2: 后续批次迁移 (Week 3-8)

继续按照相同的模式迁移其他模块...

### 批次 2: auth, user, member
### 批次 3: home, search 相关模块
### 批次 4: video, live, dynamics
### 批次 5: whisper, msg, follow
### 批次 6: mine, settings, history
### 批次 7: 剩余 40+ 轻量级模块

## 附录

### 快速命令参考

```bash
# 创建新功能模块结构
./scripts/create_clean_architecture_feature.sh <feature_name>

# 运行代码生成
flutter pub run build_runner build --delete-conflicting-outputs

# 运行静态分析
flutter analyze

# 格式化代码
dart format .

# 运行测试
flutter test
```

### 文档参考

- [迁移规范](../CLEAN_ARCHITECTURE_MIGRATION.md)
- [迁移检查清单](../MIGRATION_CHECKLIST.md)
- [设计文档](./2026-03-01-clean-architecture-migration-design.md)
