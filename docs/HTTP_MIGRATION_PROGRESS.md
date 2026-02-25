# HTTP 目录迁移进度

**开始日期:** 2026-02-25
**状态:** 🟡 进行中

---

## ✅ 已完成

### 1. 核心基础设施迁移
- ✅ `lib/core/network/` - 完整的网络层
- ✅ `lib/core/errors/` - 错误处理
- ✅ `lib/core/constants/` - API 常量拆分
- ✅ `lib/shared/data/models/loading_state.dart` - 统一响应状态

### 2. 视频 HTTP API 迁移
- ✅ `lib/features/video/data/datasources/video_remote_datasource.dart` - 新的数据源
- ✅ `lib/http/video.dart` - 使用适配器模式，内部调用新数据源
- ✅ 保留向后兼容性，现有代码无需修改

---

## 🟡 进行中

### 3. API 常量补充
- 🔄 添加缺少的常量到 `lib/core/constants/video_api_constants.dart`
- 🔄 添加缺少的导入

---

## ⏳ 待完成

### 高优先级迁移
1. **live.dart** (745行)
   - 目标: `lib/features/live/data/datasources/live_remote_datasource.dart`
   - 优先级: 高
   - 复杂度: 中

2. **login.dart** (532行)
   - 目标: `lib/features/auth/data/datasources/auth_remote_datasource.dart`
   - 优先级: 高
   - 复杂度: 中

3. **dynamics.dart** (780行)
   - 目标: `lib/features/dynamics/data/datasources/dynamics_remote_datasource.dart`
   - 优先级: 高
   - 复杂度: 高

4. **user.dart** (571行)
   - 目标: `lib/features/user/data/datasources/user_remote_datasource.dart`
   - 优先级: 高
   - 复杂度: 中

5. **member.dart** (796行)
   - 目标: `lib/features/member/data/datasources/member_remote_datasource.dart`
   - 优先级: 高
   - 复杂度: 高

6. **fav.dart** (741行)
   - 目标: `lib/features/fav/data/datasources/fav_remote_datasource.dart`
   - 优先级: 中
   - 复杂度: 中

7. **reply.dart** (260行)
   - 目标: `lib/features/reply/data/datasources/reply_remote_datasource.dart`
   - 优先级: 中
   - 复杂度: 中

8. **search.dart** (308行)
   - 目标: `lib/features/search/data/datasources/search_remote_datasource.dart`
   - 优先级: 中
   - 复杂度: 中

9. **follow.dart** (29行)
   - 目标: `lib/features/follow/data/datasources/follow_remote_datasource.dart`
   - 优先级: 低
   - 复杂度: 低

### 中优先级迁移
10. **danmaku.dart** (186行)
11. **download.dart** (238行)
12. **msg.dart** (637行)
13. **music.dart** (65行)
14. **pgc.dart** (257行)
15. **sponsor_block.dart** (232行)

### 低优先级迁移
16. **black.dart** (28行)
17. **danmaku_block.dart** (53行)
18. **fan.dart** (29行)
19. **match.dart** (22行)
20. **validate.dart** (52行)

---

## 📋 迁移策略

### 适配器模式（推荐用于渐进式迁移）

```
旧API层 (保持兼容)
    ↓
适配器层 (逐步替换)
    ↓
新数据源层 (干净架构)
```

**优点:**
- ✅ 不破坏现有代码
- ✅ 可以逐步迁移
- ✅ 易于测试和验证
- ✅ 支持新旧代码共存

**实现步骤:**
1. 创建新的数据源 (`*_remote_datasource.dart`)
2. 创建适配器，内部调用新数据源
3. 替换旧文件为适配器
4. 逐步更新调用方代码
5. 移除适配器层

### 快速迁移命令

```bash
# 1. 创建目录
mkdir -p lib/features/{feature}/data/datasources

# 2. 备份原文件
mv lib/http/{file}.dart lib/http/{file}.dart.bak

# 3. 创建适配器（基于 video.dart 模板）

# 4. 测试验证
flutter analyze

# 5. 提交变更
git add -A
git commit -m "feat: migrate {file} to clean architecture"
```

---

## 📊 统计

| 类别 | 数量 | 已完成 | 进行中 | 待完成 |
|-----|------|--------|--------|--------|
| 核心文件 | 8 | 8 | 0 | 0 |
| 高优先级业务文件 | 9 | 1 | 0 | 8 |
| 中优先级业务文件 | 6 | 0 | 0 | 6 |
| 低优先级业务文件 | 5 | 0 | 0 | 5 |
| **总计** | **28** | **10** | **0** | **18** |

**完成度:** 36% (10/28)

---

## 🎯 下一步

1. ✅ 完成 video.dart 常量补充
2. ⏳ 迁移 live.dart
3. ⏳ 迁移 login.dart
4. ⏳ 迁移 dynamics.dart
5. ⏳ 批量迁移小型文件

---

**最后更新:** 2026-02-25
