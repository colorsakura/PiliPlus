# contact Feature

contact 功能模块。

## 架构

本特性采用**干净架构（Clean Architecture）**设计。

## 目录结构

\`\`\`
lib/features/contact/
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
