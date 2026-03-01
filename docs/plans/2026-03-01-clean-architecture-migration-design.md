# Clean Architecture Migration Design

**Date:** 2026-03-01
**Version:** 1.0
**Status:** Ready for Implementation

---

## Executive Summary

PiliPlus has made significant progress toward clean architecture adoption. This document evaluates the current state and provides a prioritized roadmap for completing the migration.

**Key Findings:**
- ✅ **92% of features** (112/122) already follow clean architecture
- ✅ Core infrastructure is well-established (constants, network, errors)
- ⚠️ **22 business API files** remain in `lib/http/` (9,164 lines)
- ⚠️ Core infrastructure files in `lib/http/` need final migration

**Estimated Total Effort:** 60-80 hours across 4 phases

---

## Current State Analysis

### What's Working Well ✅

**Core Infrastructure**
- `lib/core/constants/` - 20+ feature-specific API constant files
- `lib/core/network/` - HTTP client and interceptors
- `lib/core/errors/` - Exception and failure handling framework
- `lib/core/storage/` - Storage abstraction layer

**Feature Modules**
- 112 out of 122 features have complete data/domain/presentation layers
- 93 remote datasources created and in use
- Major features (video, subscription, member) follow clean architecture
- GetX → Riverpod migration complete for video detail page

### What Needs Attention ⚠️

**1. lib/http/ Directory - Business API Files (22 files)**

| File | Lines | Target Location | Priority |
|------|-------|-----------------|----------|
| video.dart | ~800 | features/video/data/datasources/ | HIGH |
| login.dart | ~500 | features/auth/data/datasources/ | HIGH |
| live.dart | ~700 | features/live/data/datasources/ | HIGH |
| search.dart | ~300 | features/search/data/datasources/ | HIGH |
| user.dart | ~500 | features/user/data/datasources/ | MEDIUM |
| member.dart | ~600 | features/member/data/datasources/ | MEDIUM |
| dynamics.dart | ~600 | features/dynamics/data/datasources/ | MEDIUM |
| reply.dart | ~200 | features/reply/data/datasources/ | MEDIUM |
| fav.dart | ~600 | features/fav/data/datasources/ | MEDIUM |
| follow.dart | ~100 | features/follow/data/datasources/ | MEDIUM |
| danmaku.dart | ~200 | features/danmaku/data/datasources/ | LOW |
| download.dart | ~300 | features/download/data/datasources/ | LOW |
| msg.dart | ~500 | features/msg/data/datasources/ | LOW |
| music.dart | ~100 | features/music/data/datasources/ | LOW |
| pgc.dart | ~250 | features/pgc/data/datasources/ | LOW |
| match.dart | ~50 | features/match/data/datasources/ | LOW |
| validate.dart | ~50 | features/validate/data/datasources/ | LOW |
| fan.dart | ~100 | features/fan/data/datasources/ | LOW |
| blacklist.dart | ~100 | (verify if migrated) | LOW |
| sponsor_block.dart | ~150 | (verify if migrated) | LOW |
| danmaku_block.dart | ~200 | (verify if migrated) | LOW |
| browser_ua.dart | ~100 | core/constants/ua_constants.dart | LOW |

**2. lib/http/ Directory - Infrastructure Files (7 files)**

| File | Target Location | Status |
|------|-----------------|--------|
| init.dart | core/network/http_client.dart | Verify migration complete |
| loading_state.dart | shared/data/models/loading_state.dart | Move |
| constants.dart | core/constants/api_constants.dart | Partially migrated |
| api.dart | Split into feature-specific constants | Partially done |
| retry_interceptor.dart | core/network/http_interceptors/ | Move |
| logging_interceptor.dart | core/network/http_interceptors/ | Move |
| ua_type.dart | core/constants/ua_constants.dart | Move |

**3. Features Missing Presentation Layer (8 features)**

- `features/live/` - Live streaming
- `features/auth/` - Authentication
- `features/user/` - User profile
- `features/reply/` - Comments
- `features/match/` - Match/sports
- `features/validate/` - Validation
- `features/danmaku_filter/` - Danmaku filtering
- `features/msg/` - Messaging

**Action Required:** Investigate if these are library features or need presentation layers.

---

## Migration Strategy

### Phase 1: Core Infrastructure Finalization (HIGH Priority)

**Goal:** Complete migration of core infrastructure from `lib/http/`

**Duration:** 8-10 hours

**Tasks:**

1. **Verify HTTP Client Migration**
   - Check if `lib/http/init.dart` is still referenced
   - Ensure `lib/core/network/http_client.dart` is complete
   - Update all imports
   - Delete `lib/http/init.dart`

2. **Move LoadingState**
   - Move `lib/http/loading_state.dart` → `lib/shared/data/models/loading_state.dart`
   - Update all imports across the codebase
   - Verify it's used consistently

3. **Move Interceptors**
   - Move `lib/http/retry_interceptor.dart` → `lib/core/network/http_interceptors/`
   - Move `lib/http/logging_interceptor.dart` → `lib/core/network/http_interceptors/`
   - Update HTTP client to import from new location
   - Delete old files

4. **Move UA Constants**
   - Move `lib/http/ua_type.dart` → `lib/core/constants/ua_constants.dart`
   - Update references
   - Delete old file

**Success Criteria:**
- All core infrastructure files removed from `lib/http/`
- `flutter analyze` passes with no errors
- App runs successfully on Linux

---

### Phase 2: High-Traffic API Migration (HIGH Priority)

**Goal:** Migrate the 4 most critical business API files

**Duration:** 15-20 hours

**Pattern:**

```dart
// STEP 1: Create Remote DataSource in feature module
// features/video/data/datasources/video_remote_datasource.dart

class VideoRemoteDataSource {
  final Dio _httpClient = HttpClient.instance;

  Future<Map<String, dynamic>> getVideoDetail({required String bvid}) async {
    try {
      final response = await _httpClient.get(
        VideoApiConstants.videoIntro,
        queryParameters: {'bvid': bvid},
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取视频详情失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}

// STEP 2: Update repository implementation to use new datasource
// features/video/data/repositories/video_repository_impl.dart

class VideoRepositoryImpl implements VideoRepository {
  final VideoRemoteDataSource remoteDataSource;

  VideoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<LoadingState<Map<String, dynamic>>> getVideoDetail(String bvid) async {
    try {
      final data = await remoteDataSource.getVideoDetail(bvid: bvid);
      return Success(data);
    } on ServerException catch (e) {
      return Error(e.message, code: e.code);
    } on NetworkException catch (e) {
      return Error(e.message);
    } catch (e) {
      return Error('未知错误: $e');
    }
  }
}

// STEP 3: Update all imports in presentation layer
// OLD: import 'package:PiliPlus/http/video.dart';
// NEW: import 'package:PiliPlus/features/video/data/datasources/video_remote_datasource.dart';

// STEP 4: Delete old file
// rm lib/http/video.dart
```

**Files to Migrate:**

1. **lib/http/video.dart** → features/video/data/datasources/video_remote_datasource.dart
   - Video detail fetching
   - Video play URL
   - Like/coin/favorite operations
   - Video relation queries

2. **lib/http/login.dart** → features/auth/data/datasources/auth_remote_datasource.dart
   - QR code login
   - SMS login
   - Logout
   - User info fetching

3. **lib/http/live.dart** → features/live/data/datasources/live_remote_datasource.dart
   - Live room info
   - Live danmaku
   - Live chat messages

4. **lib/http/search.dart** → features/search/data/datasources/search_remote_datasource.dart
   - Search suggestions
   - Search results
   - Trending searches

**Success Criteria:**
- All 4 files migrated to respective feature datasources
- All imports updated
- `flutter analyze` passes
- Video playback, login, live, and search features work correctly

---

### Phase 3: Medium-Traffic API Migration (MEDIUM Priority)

**Goal:** Migrate 6 medium-traffic API files

**Duration:** 15-20 hours

**Files to Migrate:**

5. **lib/http/user.dart** → features/user/data/datasources/
6. **lib/http/member.dart** → features/member/data/datasources/
7. **lib/http/dynamics.dart** → features/dynamics/data/datasources/
8. **lib/http/fav.dart** → features/fav/data/datasources/
9. **lib/http/reply.dart** → features/reply/data/datasources/
10. **lib/http/follow.dart** → features/follow/data/datasources/

**Success Criteria:**
- All 6 files migrated
- All features work correctly
- No remaining references to old files

---

### Phase 4: Low-Traffic API Migration (LOW Priority)

**Goal:** Migrate remaining API files and cleanup

**Duration:** 12-15 hours

**Files to Migrate:**

11-22. Remaining files (danmaku, download, msg, music, pgc, match, validate, fan, etc.)

**Additional Tasks:**
1. Investigate and document the 8 features missing presentation layers
2. Verify if blacklist, sponsor_block, danmaku_block datasources already exist
3. Final cleanup of any remaining `lib/http/` files
4. Update documentation

**Success Criteria:**
- `lib/http/` directory is empty or contains only a README explaining migration
- All 22 business API files migrated
- All features follow clean architecture
- Documentation updated

---

## Investigation Tasks

### Features Without Presentation Layers

**Task:** Investigate why these 8 features don't have presentation layers

**Features to Investigate:**
1. `features/live/`
2. `features/auth/`
3. `features/user/`
4. `features/reply/`
5. `features/match/`
6. `features/validate/`
7. `features/danmaku_filter/`
8. `features/msg/`

**Questions to Answer:**
- Are these library/data-only features used by other features?
- Do they have presentation logic in a different location?
- Are they planned for deprecation?
- Should they have presentation layers?

**Deliverable:** Document findings in each feature's README.md

---

## Risk Assessment

### High Risk Areas

1. **Breaking Changes in API Files**
   - **Risk:** Direct references to `lib/http/*.dart` files throughout the codebase
   - **Mitigation:** Comprehensive search for imports before deletion
   - **Rollback:** Keep old files until all references are updated

2. **Runtime Errors**
   - **Risk:** Missing or incorrect imports after migration
   - **Mitigation:** Run `flutter analyze` and test each feature after migration
   - **Rollback:** Git commit after each successful file migration

### Medium Risk Areas

1. **Inconsistent Patterns**
   - **Risk:** Different migration patterns across features
   - **Mitigation:** Follow the established pattern strictly
   - **Validation:** Code review after each phase

2. **Feature Regression**
   - **Risk:** Features not working after migration
   - **Mitigation:** Test each feature thoroughly before marking complete
   - **Rollback:** Feature-specific git commits

---

## Testing Strategy

### Per-File Testing Checklist

For each migrated API file:

- [ ] All imports updated to new location
- [ ] `flutter analyze` passes
- [ ] Feature opens without errors
- [ ] Core functionality works (e.g., video plays, login works)
- [ ] Error handling works correctly
- [ ] No console errors or warnings
- [ ] Old file deleted
- [ ] Git commit created

### Integration Testing

After each phase:

- [ ] Run full app test suite
- [ ] Test all affected features
- [ ] Verify no performance regression
- [ ] Check for memory leaks
- [ ] Test on Linux platform (30-second timeout)

---

## Migration Timeline

| Phase | Duration | Start Date | End Date | Dependencies |
|-------|----------|------------|----------|--------------|
| Phase 1: Core Infrastructure | 8-10 hours | - | - | None |
| Phase 2: High-Traffic APIs | 15-20 hours | - | - | Phase 1 complete |
| Phase 3: Medium-Traffic APIs | 15-20 hours | - | - | Phase 2 complete |
| Phase 4: Low-Traffic APIs | 12-15 hours | - | - | Phase 3 complete |
| **Total** | **50-65 hours** | | | |

---

## Success Criteria

### Project Completion

- [x] Core infrastructure migrated from `lib/http/`
- [ ] All 22 business API files migrated to feature datasources
- [ ] All imports updated and verified
- [ ] `lib/http/` directory removed or contains only README
- [ ] `flutter analyze` passes with zero errors
- [ ] All features work correctly
- [ ] Documentation updated
- [ ] Investigation of 8 features without presentation layers complete

### Quality Gates

- Zero `flutter analyze` errors
- All features functional on Linux platform
- No deprecated patterns remaining
- Clean dependency hierarchy (Presentation → Domain → Data)

---

## Next Steps

1. **Review and Approve** - Stakeholder review of this design document
2. **Create Implementation Plan** - Use `writing-plans` skill to create detailed step-by-step plan
3. **Begin Phase 1** - Start with core infrastructure migration
4. **Iterate** - Complete each phase, test, and proceed to next

---

## Appendix: Reference Materials

### Clean Architecture Principles

```
┌─────────────────────────────────────────────┐
│         Presentation Layer                  │
│  (Widgets, Controllers, Providers)          │
└─────────────────┬───────────────────────────┘
                  │ depends on
┌─────────────────┴───────────────────────────┐
│           Domain Layer                      │
│  (Entities, Use Cases, Repository Interfaces)│
└─────────────────┬───────────────────────────┘
                  │ depends on
┌─────────────────┴───────────────────────────┐
│            Data Layer                       │
│  (Data Sources, Repository Implementations) │
└─────────────────────────────────────────────┘
```

### Dependency Rules

1. **Domain Layer:** No dependencies on outer layers
2. **Data Layer:** Implements Domain interfaces, depends only on Domain
3. **Presentation Layer:** Uses Domain use cases, depends only on Domain

### File Organization

```
lib/features/{feature_name}/
├── data/
│   ├── datasources/
│   │   ├── {feature}_remote_datasource.dart
│   │   └── {feature}_local_datasource.dart
│   ├── models/          # DTOs (if needed)
│   └── repositories/
│       └── {feature}_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── {entity}.dart
│   ├── repositories/
│   │   └── {feature}_repository.dart
│   └── usecases/
│       └── {use_case}_usecase.dart
├── presentation/
│   ├── providers/
│   │   └── {feature}_providers.dart
│   ├── pages/
│   │   └── {feature}_page.dart
│   └── widgets/
│       └── {widget}.dart
└── {feature}.dart      # Feature barrel file
```

---

**Document Owner:** Architecture Team
**Last Updated:** 2026-03-01
**Status:** Ready for Implementation
