<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
</div>



<div align="center">
    <h1>PiliPlus</h1>
<div align="center">

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/colorsakura/PiliPlus)

</div>
    <p>使用Flutter开发的BiliBili第三方客户端</p>
    
<img src="assets/screenshots/510shots_so.png" width="32%" alt="home" />
<img src="assets/screenshots/174shots_so.png" width="32%" alt="home" />
<img src="assets/screenshots/850shots_so.png" width="32%" alt="home" />
<br/>
<img src="assets/screenshots/main_screen.png" width="96%" alt="home" />
<br/>
</div>


<br/>

## 适配平台

- [x] Android
- [x] Windows
- [x] Linux
- [ ] Mac
- [ ] IOS
- [ ] iPadOS

[![Packaging status](https://repology.org/badge/vertical-allrepos/piliplus.svg)](https://repology.org/project/piliplus/versions)

当前版本使用 Claude Code[GLM5] 进行了架构上的完全重构，避免模块之间依赖混乱。

<details>
<summary>🏗️ Clean Architecture 架构说明</summary>

### 架构概览

本项目采用 **Clean Architecture**（整洁架构）模式重构，实现 **106/122 个功能模块（86.8%）** 的架构规范化。

### 三层架构

```
┌─────────────────────────────────────────────────────────┐
│                  Presentation Layer                      │
│  (UI Components, Controllers, Pages)                    │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                    Domain Layer                          │
│  (Entities, Repositories Interfaces, Use Cases)         │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                     Data Layer                           │
│  (Remote Data Sources, Repository Implementations)      │
└─────────────────────────────────────────────────────────┘
```

### 架构优势

- **关注点分离**: 业务逻辑与 UI 完全解耦
- **可测试性**: 每层可独立测试
- **可维护性**: 清晰的依赖关系，易于修改和扩展
- **代码复用**: Use Cases 和 Repositories 可在不同场景复用

### 模块结构

每个功能模块遵循以下结构：

```
lib/features/feature_name/
├── domain/              # 领域层
│   ├── entities/        # 实体（参数、模型）
│   ├── repositories/    # 仓储接口
│   └── usecases/        # 用例（业务逻辑）
├── data/                # 数据层
│   ├── datasources/     # 数据源接口和实现
│   └── repositories/    # 仓储实现
├── presentation/        # 表现层
│   ├── pages/           # 页面
│   ├── controllers/     # 控制器
│   └── widgets/         # 组件
├── README.md            # 模块文档
└── feature_name.dart    # 统一导出
```

### 技术栈

- **状态管理**: GetX / Riverpod
- **网络请求**: Dio (封装为 Remote Data Sources)
- **类型安全**: 完整的 Dart 类型注解
- **错误处理**: 统一的 LoadingState 封装

</details>

<br/>

## 下载

可以通过右侧release进行下载或拉取代码到本地进行编译

<br/>

## 声明

此项目（PiliPlus）是个人为了兴趣而开发，仅用于学习和测试，请于下载后24小时内删除。
所用API皆从官方网站收集，不提供任何破解内容。
在此致敬原作者：[guozhigq/pilipala](https://github.com/guozhigq/pilipala)
在此致敬上游作者：[orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
本仓库做了更激进的修改，感谢原作者的开源精神。

感谢使用


<br/>

## 致谢

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- 等等

<br/>
<br/>
<br/>

## Star History

<a href="https://www.star-history.com/#colorsakura/PiliPlus&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=colorsakura/PiliPlus&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=colorsakura/PiliPlus&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=colorsakura/PiliPlus&type=Date" />
 </picture>
</a>
