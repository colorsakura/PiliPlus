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
