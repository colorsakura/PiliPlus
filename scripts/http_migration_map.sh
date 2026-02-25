#!/bin/bash
# HTTP 迁移映射表
# 用于批量迁移 lib/http/ 目录到对应的 features

cat << 'EOF'
# HTTP 文件迁移映射

## 已完成
- video.dart → features/video/data/datasources/video_remote_datasource.dart

## 待迁移 - 高优先级
1. live.dart → features/live/data/datasources/live_remote_datasource.dart
2. login.dart → features/auth/data/datasources/auth_remote_datasource.dart
3. dynamics.dart → features/dynamics/data/datasources/dynamics_remote_datasource.dart
4. user.dart → features/user/data/datasources/user_remote_datasource.dart
5. member.dart → features/member/data/datasources/member_remote_datasource.dart
6. fav.dart → features/fav/data/datasources/fav_remote_datasource.dart
7. reply.dart → features/reply/data/datasources/reply_remote_datasource.dart
8. search.dart → features/search/data/datasources/search_remote_datasource.dart
9. follow.dart → features/follow/data/datasources/follow_remote_datasource.dart

## 待迁移 - 中优先级
10. danmaku.dart → features/danmaku/data/datasources/
11. download.dart → features/download/data/datasources/
12. msg.dart → features/message/data/datasources/
13. music.dart → features/music/data/datasources/
14. pgc.dart → features/pgc/data/datasources/
15. sponsor_block.dart → features/sponsor_block/data/datasources/

## 待迁移 - 低优先级
16. black.dart → features/blacklist/data/datasources/
17. fan.dart → features/fan/data/datasources/
18. match.dart → features/match/data/datasources/
19. validate.dart → features/validate/data/datasources/
20. danmaku_block.dart → features/danmaku_block/data/datasources/

## 不需要迁移（基础设施）
- init.dart → 已迁移到 lib/core/network/http_client.dart
- loading_state.dart → 已迁移到 lib/shared/data/models/loading_state.dart
- constants.dart → 已迁移到 lib/core/constants/
- api.dart → 已拆分到各个 API 常量文件
- retry_interceptor.dart → 已迁移到 lib/core/network/http_interceptors/
- logging_interceptor.dart → 已迁移到 lib/core/network/http_interceptors/
- ua_type.dart → 待定（可能移到 core/constants/）
- sponsor_block_api.dart → 合并到 sponsor_block.dart

EOF
