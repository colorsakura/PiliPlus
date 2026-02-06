# Search API Rust Migration Plan

**Date:** 2025-02-07
**Status:** 🔄 In Progress
**API Endpoint:** Video Search API
**Implementation:** Rust with automatic Flutter fallback

---

## Scope

**Initial Focus:** Video Search Only (most commonly used)

The Search API has multiple types (video, live_room, bili_user, media_bangumi, article). We'll start with **video search** as it's the most frequently used.

**Endpoints:**
- `searchByType(SearchType.video, ...)` - Search for videos
- Future: Add support for other search types

---

## Migration Phases

### Phase 1: Create Rust Search API Implementation
**Goal:** Implement video search in Rust

**Tasks:**
1. Create `rust/src/api/search.rs` (use `.bak` as starting point)
2. Implement `search_videos()` function
3. Add WBI signature support
4. Handle pagination
5. Return search results

**Rust Function Signature:**
```rust
#[frb]
pub async fn search_videos(
    keyword: String,
    page: i32,
    page_size: i32,
    order: Option<String>,
    duration: Option<i32>,
    tids: Option<i32>,
) -> Result<SearchVideoResult, SerializableError>
```

### Phase 2: Update Rust Search Models
**Goal:** Match Flutter search models

**Tasks:**
1. Create/Search for `SearchVideoResult` model
2. Create `SearchVideoItem` model
3. Match Flutter `SearchVideoItemModel` structure
4. Handle nullable fields

### Phase 3: Create Search Adapter
**Goal:** Convert Rust models to Flutter models

**Tasks:**
1. Create `lib/src/rust/adapters/search_adapter.dart`
2. Implement `fromRust()` for video results
3. Handle list conversion

### Phase 4: Create Search API Facade
**Goal:** Route between Rust and Flutter

**Tasks:**
1. Create `lib/http/search_api_facade.dart`
2. Implement `searchVideos()` method
3. Add feature flag check
4. Add automatic fallback

### Phase 5: Add Feature Flag
**Goal:** Control rollout

**Tasks:**
1. Add `useRustSearchApi` to `SettingBoxKey`
2. Add `Pref.useRustSearchApi` getter
3. Set default to `true`

### Phase 6: Integrate Facade into SearchHttp
**Goal:** Replace direct API calls

**Tasks:**
1. Update `SearchHttp.searchByType()` for video type
2. Route to facade for `SearchType.video`
3. Keep other types as Flutter-only for now

### Phase 7: Global Rollout
**Goal:** Enable by default

**Tasks:**
1. Verify compilation
2. Test with real searches
3. Enable feature flag
4. Monitor metrics

---

## Data Models

### Rust SearchVideoResult
```rust
pub struct SearchVideoResult {
    pub items: Vec<SearchVideoItem>,
    pub page: i32,
    pub page_size: i32,
    pub num_results: i32,
}
```

### Rust SearchVideoItem
```rust
pub struct SearchVideoItem {
    pub bvid: String,
    pub aid: i64,
    pub title: String,
    pub description: String,
    pub owner_name: String,
    pub owner_face: String,
    pub mid: i64,
    pub duration: String,
    pub view_count: i64,
    pub pubdate: i64,
}
```

### Flutter Mapping
- `SearchVideoItem` → `SearchVideoItemModel`
- Field name mappings needed
- Null handling for optional fields

---

## Architecture

```
┌─────────────────────────────────────────────┐
│           SearchHttp (Public Interface)      │
│  - searchByType(SearchType.video, ...)       │
└─────────────────┬───────────────────────────┘
                  │
┌─────────────────┴───────────────────────────┐
│       SearchApiFacade (Router)              │
│  - Checks Pref.useRustSearchApi             │
│  - Routes to Rust or Flutter                │
│  - Automatic fallback on errors             │
└──────┬──────────────────┬───────────────────┘
       │ Rust (default)    │ Flutter (fallback)
┌──────┴──────────┐   ┌────────┴─────────┐
│ Rust FFI Bridge │   │ Request().get()  │
│ searchVideos()  │   │ Api.searchByType│
└──────┬──────────┘   └──────────────────┘
       │
┌──────┴──────────┐
│ Rust Models     │
│ - SearchVideoResult
│ - SearchVideoItem
└─────────────────┘
       │
┌──────┴──────────┐
│ SearchAdapter   │
│ fromRust()      │
└─────────────────┘
       │
┌──────┴──────────┐
│ SearchVideoItemModel
│ (Flutter)       │
└─────────────────┘
```

---

## Implementation Notes

**Complexity Factors:**
1. **WBI Signature:** Required for search API
2. **Multiple Types:** Video, live, user, media, article
3. **Pagination:** Page-based, not cursor-based
4. **Filter Options:** Duration, TID, order, etc.

**Simplifications:**
1. Start with video search only
2. Support basic filters (keyword, page, order)
3. Add more filters later

**Error Handling:**
- Network errors → Fallback to Flutter
- Parse errors → Fallback to Flutter
- WBI signature errors → Log and return error

---

## Success Criteria

- ✅ Video search works via Rust
- ✅ Performance < 500ms for search
- ✅ Results match Flutter implementation
- ✅ Feature flag toggles correctly
- ✅ Automatic fallback works
- ✅ No breaking changes

---

**Estimated Time:** 2-3 hours (video search only)
**Full Search API:** 5-7 days (all search types)
