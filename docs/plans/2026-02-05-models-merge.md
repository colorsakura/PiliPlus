# Models Directory Merge Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Merge `lib/models/` into `lib/models_new/` and rename `models_new` to `models`, consolidating all data models into a single unified directory.

**Architecture:** Migration strategy using `models_new` as the base (466 files) and migrating 81 unique files from `models/`, including 59 common type definitions and 22 feature-specific models, followed by updating all imports across 462+ files.

**Tech Stack:** Flutter/Dart, GetX state management, Hive (local storage), FVM (Flutter version management)

---

## Task 1: Preparation and Safety Setup

**Files:**
- Create: `docs/plans/2026-02-05-models-merge-checkpoint.md` (checkpoint tracking)

**Step 1: Create checkpoint tag**

```bash
git tag before-models-merge
git push origin before-models-merge
```

**Step 2: Verify current branch**

```bash
git branch --show-current
```

Expected: `merge_models` (or current working branch)

**Step 3: Create checkpoint tracking file**

```bash
cat > docs/plans/2026-02-05-models-merge-checkpoint.md << 'EOF'
# Models Merge Checkpoint Log

## Pre-Merge Status
- Date: 2026-02-05
- Branch: merge_models
- Tag: before-models-merge

## Checkpoints
EOF
```

**Step 4: Verify models directories exist**

```bash
ls -la lib/models/ | head -20
ls -la lib/models_new/ | head -20
```

Expected: Both directories exist with files

**Step 5: Commit checkpoint setup**

```bash
git add docs/plans/2026-02-05-models-merge-checkpoint.md
git commit -m "chore: setup checkpoint tracking for models merge"
```

---

## Task 2: Create models_new/common/ Directory Structure

**Files:**
- Create: `lib/models_new/common/`
- Create: `lib/models_new/common/dynamic/`
- Create: `lib/models_new/common/live/`
- Create: `lib/models_new/common/member/`
- Create: `lib/models_new/common/msg/`
- Create: `lib/models_new/common/reply/`
- Create: `lib/models_new/common/search/`
- Create: `lib/models_new/common/sponsor_block/`
- Create: `lib/models_new/common/theme/`
- Create: `lib/models_new/common/video/`

**Step 1: Create base common directory**

```bash
mkdir -p lib/models_new/common
```

**Step 2: Create subdirectories**

```bash
mkdir -p lib/models_new/common/dynamic
mkdir -p lib/models_new/common/live
mkdir -p lib/models_new/common/member
mkdir -p lib/models_new/common/msg
mkdir -p lib/models_new/common/reply
mkdir -p lib/models_new/common/search
mkdir -p lib/models_new/common/sponsor_block
mkdir -p lib/models_new/common/theme
mkdir -p lib/models_new/common/video
```

**Step 3: Verify directory structure**

```bash
tree lib/models_new/common -L 1
```

Expected: All subdirectories created

**Step 4: Commit directory structure**

```bash
git add lib/models_new/common/
git commit -m "chore: create models_new/common/ directory structure"
```

---

## Task 3: Migrate Basic Enums and Types (Root Level)

**Files:**
- Create: `lib/models_new/common/account_type.dart` (copy from `lib/models/common/account_type.dart`)
- Create: `lib/models_new/common/audio_normalization.dart`
- Create: `lib/models_new/common/avatar_badge_type.dart`
- Create: `lib/models_new/common/badge_type.dart`
- Create: `lib/models_new/common/dm_block_type.dart`
- Create: `lib/models_new/common/fav_order_type.dart`
- Create: `lib/models_new/common/fav_type.dart`
- Create: `lib/models_new/common/follow_order_type.dart`
- Create: `lib/models_new/common/home_tab_type.dart`
- Create: `lib/models_new/common/image_preview_type.dart`
- Create: `lib/models_new/common/image_type.dart`
- Create: `lib/models_new/common/later_view_type.dart`
- Create: `lib/models_new/common/nav_bar_config.dart`
- Create: `lib/models_new/common/pgc_review_type.dart`
- Create: `lib/models_new/common/publish_panel_type.dart`
- Create: `lib/models_new/common/rank_type.dart`
- Create: `lib/models_new/common/setting_type.dart`
- Create: `lib/models_new/common/stat_type.dart`
- Create: `lib/models_new/common/super_chat_type.dart`
- Create: `lib/models_new/common/super_resolution_type.dart`
- Create: `lib/models_new/common/webview_menu_type.dart`
- Create: `lib/models_new/common/enum_with_label.dart`
- Create: `lib/models_new/common/episode_panel_type.dart`

**Step 1: Copy basic enum files**

```bash
cp lib/models/common/account_type.dart lib/models_new/common/
cp lib/models/common/audio_normalization.dart lib/models_new/common/
cp lib/models/common/avatar_badge_type.dart lib/models_new/common/
cp lib/models/common/badge_type.dart lib/models_new/common/
cp lib/models/common/dm_block_type.dart lib/models_new/common/
cp lib/models/common/fav_order_type.dart lib/models_new/common/
cp lib/models/common/fav_type.dart lib/models_new/common/
cp lib/models/common/follow_order_type.dart lib/models_new/common/
cp lib/models/common/home_tab_type.dart lib/models_new/common/
cp lib/models/common/image_preview_type.dart lib/models_new/common/
cp lib/models/common/image_type.dart lib/models_new/common/
cp lib/models/common/later_view_type.dart lib/models_new/common/
cp lib/models/common/nav_bar_config.dart lib/models_new/common/
cp lib/models/common/pgc_review_type.dart lib/models_new/common/
cp lib/models/common/publish_panel_type.dart lib/models_new/common/
cp lib/models/common/rank_type.dart lib/models_new/common/
cp lib/models/common/setting_type.dart lib/models_new/common/
cp lib/models/common/stat_type.dart lib/models_new/common/
cp lib/models/common/super_chat_type.dart lib/models_new/common/
cp lib/models/common/super_resolution_type.dart lib/models_new/common/
cp lib/models/common/webview_menu_type.dart lib/models_new/common/
cp lib/models/common/enum_with_label.dart lib/models_new/common/
cp lib/models/common/episode_panel_type.dart lib/models_new/common/
```

**Step 2: Verify files copied**

```bash
ls lib/models_new/common/*.dart | wc -l
```

Expected: 23 files

**Step 3: Analyze imports in copied files**

```bash
grep -h "^import" lib/models_new/common/*.dart | sort -u
```

Note: Check if any imports reference `package:PiliPlus/models/common/` that need updating

**Step 4: Run static analysis**

```bash
fvm flutter analyze lib/models_new/common/
```

Expected: No errors (warnings about unused files are OK at this stage)

**Step 5: Commit basic types migration**

```bash
git add lib/models_new/common/
git commit -m "feat(migrate): add basic enum types to models_new/common/"
```

---

## Task 4: Migrate Video Types

**Files:**
- Create: `lib/models_new/common/video/audio_quality.dart`
- Create: `lib/models_new/common/video/cdn_type.dart`
- Create: `lib/models_new/common/video/live_quality.dart`
- Create: `lib/models_new/common/video/source_type.dart`
- Create: `lib/models_new/common/video/subtitle_pref_type.dart`
- Create: `lib/models_new/common/video/video_decode_type.dart`
- Create: `lib/models_new/common/video/video_quality.dart`
- Create: `lib/models_new/common/video/video_type.dart`

**Step 1: Copy video type files**

```bash
cp lib/models/common/audio_quality.dart lib/models_new/common/video/
cp lib/models/common/cdn_type.dart lib/models_new/common/video/
cp lib/models/common/live_quality.dart lib/models_new/common/video/
cp lib/models/common/source_type.dart lib/models_new/common/video/
cp lib/models/common/subtitle_pref_type.dart lib/models_new/common/video/
cp lib/models/common/video_decode_type.dart lib/models_new/common/video/
cp lib/models/common/video_quality.dart lib/models_new/common/video/
cp lib/models/common/video_type.dart lib/models_new/common/video/
```

**Step 2: Verify files copied**

```bash
ls lib/models_new/common/video/
```

Expected: 8 files

**Step 3: Commit video types**

```bash
git add lib/models_new/common/video/
git commit -m "feat(migrate): add video type enums to models_new/common/video/"
```

---

## Task 5: Migrate Theme Types

**Files:**
- Create: `lib/models_new/common/theme/theme_color_type.dart`
- Create: `lib/models_new/common/theme/theme_type.dart`

**Step 1: Copy theme files**

```bash
cp lib/models/common/theme_color_type.dart lib/models_new/common/theme/
cp lib/models/common/theme_type.dart lib/models_new/common/theme/
```

**Step 2: Verify and commit**

```bash
git add lib/models_new/common/theme/
git commit -m "feat(migrate): add theme types to models_new/common/theme/"
```

---

## Task 6: Migrate Dynamic Types

**Files:**
- Create: `lib/models_new/common/dynamic/dynamic_badge_mode.dart`
- Create: `lib/models_new/common/dynamic/dynamics_type.dart`
- Create: `lib/models_new/common/dynamic/up_panel_position.dart`

**Step 1: Copy dynamic files**

```bash
cp lib/models/common/dynamic_badge_mode.dart lib/models_new/common/dynamic/
cp lib/models/common/dynamics_type.dart lib/models_new/common/dynamic/
cp lib/models/common/up_panel_position.dart lib/models_new/common/dynamic/
```

**Step 2: Verify and commit**

```bash
git add lib/models_new/common/dynamic/
git commit -m "feat(migrate): add dynamic types to models_new/common/dynamic/"
```

---

## Task 7: Migrate Member Types

**Files:**
- Create: `lib/models_new/common/member/contribute_type.dart`
- Create: `lib/models_new/common/member/profile_type.dart`
- Create: `lib/models_new/common/member/search_type.dart`
- Create: `lib/models_new/common/member/tab_type.dart`
- Create: `lib/models_new/common/member/user_info_type.dart`

**Step 1: Copy member files**

```bash
cp lib/models/common/contribute_type.dart lib/models_new/common/member/
cp lib/models/common/profile_type.dart lib/models_new/common/member/
cp lib/models/common/search_type.dart lib/models_new/common/member/
cp lib/models/common/tab_type.dart lib/models_new/common/member/
cp lib/models/common/user_info_type.dart lib/models_new/common/member/
```

**Step 2: Verify and commit**

```bash
git add lib/models_new/common/member/
git commit -m "feat(migrate): add member types to models_new/common/member/"
```

---

## Task 8: Migrate Reply Types

**Files:**
- Create: `lib/models_new/common/reply/reply_option_type.dart`
- Create: `lib/models_new/common/reply/reply_search_type.dart`
- Create: `lib/models_new/common/reply/reply_sort_type.dart`
- Create: `lib/models_new/common/reply/reply_type.dart`

**Step 1: Copy reply files**

```bash
cp lib/models/common/reply_option_type.dart lib/models_new/common/reply/
cp lib/models/common/reply_search_type.dart lib/models_new/common/reply/
cp lib/models/common/reply_sort_type.dart lib/models_new/common/reply/
cp lib/models/common/reply_type.dart lib/models_new/common/reply/
```

**Step 2: Verify and commit**

```bash
git add lib/models_new/common/reply/
git commit -m "feat(migrate): add reply types to models_new/common/reply/"
```

---

## Task 9: Migrate Search Types

**Files:**
- Create: `lib/models_new/common/search/article_search_type.dart`
- Create: `lib/models_new/common/search/search_type.dart`
- Create: `lib/models_new/common/search/user_search_type.dart`
- Create: `lib/models_new/common/search/video_search_type.dart`

**Step 1: Copy search files**

```bash
cp lib/models/common/article_search_type.dart lib/models_new/common/search/
cp lib/models/common/search_type.dart lib/models_new/common/search/
cp lib/models/common/user_search_type.dart lib/models_new/common/search/
cp lib/models/common/video_search_type.dart lib/models_new/common/search/
```

**Step 2: Verify and commit**

```bash
git add lib/models_new/common/search/
git commit -m "feat(migrate): add search types to models_new/common/search/"
```

---

## Task 10: Migrate Live Types

**Files:**
- Create: `lib/models_new/common/live/live_contribution_rank_type.dart`
- Create: `lib/models_new/common/live/live_dm_silent_type.dart`
- Create: `lib/models_new/common/live/live_search_type.dart`

**Step 1: Copy live files**

```bash
cp lib/models/common/live_contribution_rank_type.dart lib/models_new/common/live/
cp lib/models/common/live_dm_silent_type.dart lib/models_new/common/live/
cp lib/models/common/live_search_type.dart lib/models_new/common/live/
```

**Step 2: Verify and commit**

```bash
git add lib/models_new/common/live/
git commit -m "feat(migrate): add live types to models_new/common/live/"
```

---

## Task 11: Migrate Message Types

**Files:**
- Create: `lib/models_new/common/msg/msg_type.dart`
- Create: `lib/models_new/common/msg/msg_unread_type.dart`

**Step 1: Copy message files**

```bash
cp lib/models/common/msg_type.dart lib/models_new/common/msg/
cp lib/models/common/msg_unread_type.dart lib/models_new/common/msg/
```

**Step 2: Verify and commit**

```bash
git add lib/models_new/common/msg/
git commit -m "feat(migrate): add message types to models_new/common/msg/"
```

---

## Task 12: Migrate Sponsor Block Types

**Files:**
- Create: `lib/models_new/common/sponsor_block/action_type.dart`
- Create: `lib/models_new/common/sponsor_block/post_segment_model.dart`
- Create: `lib/models_new/common/sponsor_block/segment_model.dart`
- Create: `lib/models_new/common/sponsor_block/segment_type.dart`
- Create: `lib/models_new/common/sponsor_block/skip_type.dart`

**Step 1: Copy sponsor block files**

```bash
cp lib/models/common/action_type.dart lib/models_new/common/sponsor_block/
cp lib/models/common/post_segment_model.dart lib/models_new/common/sponsor_block/
cp lib/models/common/segment_model.dart lib/models_new/common/sponsor_block/
cp lib/models/common/segment_type.dart lib/models_new/common/sponsor_block/
cp lib/models/common/skip_type.dart lib/models_new/common/sponsor_block/
```

**Step 2: Verify and commit**

```bash
git add lib/models_new/common/sponsor_block/
git commit -m "feat(migrate): add sponsor block types to models_new/common/sponsor_block/"
```

---

## Task 13: Migrate Dynamics Models

**Files:**
- Create: `lib/models_new/dynamics/article_content_model.dart`
- Create: `lib/models_new/dynamics/result.dart`
- Create: `lib/models_new/dynamics/up.dart`
- Create: `lib/models_new/dynamics/vote_model.dart`

**Step 1: Check if dynamics directory exists in models_new**

```bash
ls -la lib/models_new/dynamics/ 2>/dev/null || echo "Directory does not exist"
```

**Step 2: Create directory if needed and copy files**

```bash
mkdir -p lib/models_new/dynamics
cp lib/models/dynamics/article_content_model.dart lib/models_new/dynamics/
cp lib/models/dynamics/result.dart lib/models_new/dynamics/
cp lib/models/dynamics/up.dart lib/models_new/dynamics/
cp lib/models/dynamics/vote_model.dart lib/models_new/dynamics/
```

**Step 3: Verify files**

```bash
ls lib/models_new/dynamics/
```

**Step 4: Update checkpoint**

```bash
echo "- Task 13: Migrated dynamics models (4 files)" >> docs/plans/2026-02-05-models-merge-checkpoint.md
```

**Step 5: Commit**

```bash
git add lib/models_new/dynamics/ docs/plans/2026-02-05-models-merge-checkpoint.md
git commit -m "feat(migrate): add dynamics models to models_new/dynamics/"
```

---

## Task 14: Migrate Home Rcmd Model

**Files:**
- Create: `lib/models_new/home/rcmd/result.dart`

**Step 1: Check if home/rcmd exists**

```bash
ls -la lib/models_new/home/rcmd/ 2>/dev/null || echo "Directory does not exist"
```

**Step 2: Create directory and copy file**

```bash
mkdir -p lib/models_new/home/rcmd
cp lib/models/home/rcmd/result.dart lib/models_new/home/rcmd/
```

**Step 3: Verify and commit**

```bash
git add lib/models_new/home/
git commit -m "feat(migrate): add home rcmd model to models_new/home/rcmd/"
```

---

## Task 15: Migrate Login Model

**Files:**
- Create: `lib/models_new/login/model.dart`

**Step 1: Check if login directory exists**

```bash
ls -la lib/models_new/login/ 2>/dev/null || echo "Directory does not exist"
```

**Step 2: Create directory and copy file**

```bash
mkdir -p lib/models_new/login
cp lib/models/login/model.dart lib/models_new/login/
```

**Step 3: Verify and commit**

```bash
git add lib/models_new/login/
git commit -m "feat(migrate): add login model to models_new/login/"
```

---

## Task 16: Migrate Member Models

**Files:**
- Create: `lib/models_new/member/info.dart`
- Create: `lib/models_new/member/tags.dart`

**Step 1: Check if member directory exists**

```bash
ls -la lib/models_new/member/ 2>/dev/null || echo "Directory does not exist"
```

**Step 2: Create directory and copy files**

```bash
mkdir -p lib/models_new/member
cp lib/models/member/info.dart lib/models_new/member/
cp lib/models/member/tags.dart lib/models_new/member/
```

**Step 3: Verify and commit**

```bash
git add lib/models_new/member/
git commit -m "feat(migrate): add member models to models_new/member/"
```

---

## Task 17: Migrate Core Models

**Files:**
- Create: `lib/models_new/model_avatar.dart`
- Create: `lib/models_new/model_hot_video_item.dart`
- Create: `lib/models_new/model_owner.dart`
- Create: `lib/models_new/model_rec_video_item.dart`
- Create: `lib/models_new/model_video.dart`
- Create: `lib/models_new/pgc_lcf.dart`

**Step 1: Copy core models to models_new root**

```bash
cp lib/models/model_avatar.dart lib/models_new/
cp lib/models/model_hot_video_item.dart lib/models_new/
cp lib/models/model_owner.dart lib/models_new/
cp lib/models/model_rec_video_item.dart lib/models_new/
cp lib/models/model_video.dart lib/models_new/
cp lib/models/pgc_lcf.dart lib/models_new/
```

**Step 2: Copy generated file for model_owner**

```bash
cp lib/models/model_owner.g.dart lib/models_new/
```

**Step 3: Verify files**

```bash
ls lib/models_new/model_*.dart lib/models_new/pgc_lcf.dart
```

**Step 4: Verify and commit**

```bash
git add lib/models_new/model_*.dart lib/models_new/pgc_lcf.dart lib/models_new/model_owner.g.dart
git commit -m "feat(migrate): add core models to models_new/"
```

---

## Task 18: Migrate Search Models

**Files:**
- Create: `lib/models_new/search/result.dart`
- Create: `lib/models_new/search/suggest.dart`

**Step 1: Check if search directory exists**

```bash
ls -la lib/models_new/search/ 2>/dev/null | head -20
```

**Step 2: Check for file name conflicts**

```bash
ls lib/models_new/search/result.dart 2>/dev/null || echo "File does not exist"
```

**Step 3: If conflict exists, rename with suffix**

```bash
# Check if result.dart exists first
if [ -f lib/models_new/search/result.dart ]; then
  # Compare files
  diff lib/models/search/result.dart lib/models_new/search/result.dart
  # If different, keep models_new version (our strategy)
  echo "Keeping models_new/search/result.dart (already exists)"
else
  # No conflict, copy the file
  cp lib/models/search/result.dart lib/models_new/search/
fi
```

**Step 4: Copy suggest.dart (if not exists)**

```bash
if [ ! -f lib/models_new/search/suggest.dart ]; then
  cp lib/models/search/suggest.dart lib/models_new/search/
fi
```

**Step 5: Verify and commit**

```bash
git add lib/models_new/search/
git commit -m "feat(migrate): add search models to models_new/search/"
```

---

## Task 19: Migrate User Models

**Files:**
- Create: `lib/models_new/user/danmaku_block.dart`
- Create: `lib/models_new/user/danmaku_rule.dart`
- Create: `lib/models_new/user/danmaku_rule_adapter.dart`
- Create: `lib/models_new/user/info.dart`
- Create: `lib/models_new/user/stat.dart`
- Create: `lib/models_new/user/info.g.dart`
- Create: `lib/models_new/user/stat.g.dart`

**Step 1: Check if user directory exists**

```bash
ls -la lib/models_new/user/ 2>/dev/null | head -20
```

**Step 2: Check for conflicts**

```bash
ls lib/models_new/user/info.dart 2>/dev/null || echo "info.dart does not exist"
ls lib/models_new/user/stat.dart 2>/dev/null || echo "stat.dart does not exist"
```

**Step 3: Copy files with conflict handling**

```bash
# Copy non-conflicting files first
cp lib/models/user/danmaku_block.dart lib/models_new/user/
cp lib/models/user/danmaku_rule.dart lib/models_new/user/
cp lib/models/user/danmaku_rule_adapter.dart lib/models_new/user/

# Handle conflicting files (keep models_new versions)
if [ -f lib/models_new/user/info.dart ]; then
  echo "Keeping models_new/user/info.dart (already exists)"
else
  cp lib/models/user/info.dart lib/models_new/user/
  cp lib/models/user/info.g.dart lib/models_new/user/
fi

if [ -f lib/models_new/user/stat.dart ]; then
  echo "Keeping models_new/user/stat.dart (already exists)"
else
  cp lib/models/user/stat.dart lib/models_new/user/
  cp lib/models/user/stat.g.dart lib/models_new/user/
fi
```

**Step 4: Verify and commit**

```bash
git add lib/models_new/user/
git commit -m "feat(migrate): add user models to models_new/user/"
```

---

## Task 20: Migrate Video Play URL Model

**Files:**
- Create: `lib/models_new/video/play/url.dart`

**Step 1: Check if video/play directory exists**

```bash
ls -la lib/models_new/video/play/ 2>/dev/null || echo "Directory does not exist"
```

**Step 2: Create directory and copy file**

```bash
mkdir -p lib/models_new/video/play
cp lib/models/video/play/url.dart lib/models_new/video/play/
```

**Step 3: Verify and commit**

```bash
git add lib/models_new/video/play/
git commit -m "feat(migrate): add video play URL model to models_new/video/play/"
```

---

## Task 21: Verify Migration Completeness

**Files:**
- None (verification only)

**Step 1: Count files in old models**

```bash
find lib/models -name "*.dart" -not -path "*/.*" | wc -l
```

Expected: ~84 files (including .g.dart)

**Step 2: List all unique files in old models**

```bash
find lib/models -name "*.dart" -not -path "*/.*" -not -name "*.g.dart" | sort
```

**Step 3: Verify all unique files migrated**

```bash
# Create a list of migrated files
echo "Checking migration completeness..."
echo "Common types: $(ls lib/models_new/common/*.dart 2>/dev/null | wc -l)"
echo "Video types: $(ls lib/models_new/common/video/*.dart 2>/dev/null | wc -l)"
echo "Theme types: $(ls lib/models_new/common/theme/*.dart 2>/dev/null | wc -l)"
echo "Dynamic types: $(ls lib_models_new/common/dynamic/*.dart 2>/dev/null | wc -l)"
echo "Dynamics models: $(ls lib/models_new/dynamics/*.dart 2>/dev/null | wc -l)"
echo "Core models: $(ls lib/models_new/model_*.dart 2>/dev/null | wc -l)"
```

**Step 4: Update checkpoint**

```bash
cat >> docs/plans/2026-02-05-models-merge-checkpoint.md << 'EOF'
## Migration Complete
- All 81 unique files migrated from lib/models/ to lib/models_new/
- Common types: models_new/common/ (59 files)
- Feature models: models_new/[feature]/ (22 files)
- Generated files: .g.dart files migrated
EOF
```

**Step 5: Commit verification**

```bash
git add docs/plans/2026-02-05-models-merge-checkpoint.md
git commit -m "chore: verify migration completeness"
```

---

## Task 22: Find All Import References to models/

**Files:**
- None (analysis only)

**Step 1: Find all files importing from models/common/**

```bash
grep -r "package:PiliPlus/models/common/" lib/ --include="*.dart" | wc -l
```

**Step 2: Find all files importing from models/ (any subdirectory)**

```bash
grep -r "package:PiliPlus/models/" lib/ --include="*.dart" | grep -v "models_new/" | wc -l
```

**Step 3: List first 20 files that need updating**

```bash
grep -rl "package:PiliPlus/models/" lib/ --include="*.dart" | grep -v "models_new" | head -20
```

**Step 4: Save import file list**

```bash
grep -rl "package:PiliPlus/models/" lib/ --include="*.dart" | grep -v "models_new" > /tmp/models_imports.txt
wc -l /tmp/models_imports.txt
```

**Step 5: Update checkpoint**

```bash
echo "- Found $(wc -l < /tmp/models_imports.txt) files needing import updates" >> docs/plans/2026-02-05-models-merge-checkpoint.md
git add docs/plans/2026-02-05-models-merge-checkpoint.md
git commit -m "chore: catalog files needing import updates"
```

---

## Task 23: Update Imports - Batch 1 (Common Types)

**Files:**
- Modify: All files importing from `models/common/` (first 20 files)

**Step 1: Read first batch of files**

```bash
head -20 /tmp/models_imports.txt
```

**Step 2: For each file, update imports**

Use the following replacement pattern:
```bash
# Replace imports from models/common/ to models_new/common/
sed -i "s|package:PiliPlus/models/common/|package:PiliPlus/models_new/common/|g" <file_path>
```

**Step 3: Process batch 1**

```bash
head -20 /tmp/models_imports.txt | while read file; do
  echo "Processing: $file"
  sed -i "s|package:PiliPlus/models/common/|package:PiliPlus/models_new/common/|g" "$file"
done
```

**Step 4: Run static analysis**

```bash
fvm flutter analyze --no-pub
```

Expected: May have some errors, fix manually if needed

**Step 5: Fix any broken imports**

```bash
# Check for any remaining models/ imports
grep -r "package:PiliPlus/models/" lib/ --include="*.dart" | grep -v "models_new" | head -10
```

**Step 6: Commit batch 1**

```bash
git add -A
git commit -m "feat(migrate): update imports batch 1 (common types - 20 files)"
```

---

## Task 24: Update Imports - Batch 2 (Continue Common Types)

**Files:**
- Modify: Next 20 files from import list

**Step 1: Get next batch**

```bash
sed -n '21,40p' /tmp/models_imports.txt
```

**Step 2: Process batch 2**

```bash
sed -n '21,40p' /tmp/models_imports.txt | while read file; do
  echo "Processing: $file"
  sed -i "s|package:PiliPlus/models/common/|package:PiliPlus/models_new/common/|g" "$file"
  # Also handle direct models/ imports (not in common/)
  sed -i "s|package:PiliPlus/models/\(user/\|member/\|dynamics/\)|package:PiliPlus/models_new/\1|g" "$file"
done
```

**Step 3: Run static analysis**

```bash
fvm flutter analyze --no-pub
```

**Step 4: Commit batch 2**

```bash
git add -A
git commit -m "feat(migrate): update imports batch 2 (20 files)"
```

---

## Task 25-35: Continue Import Batches

*(Similar pattern repeated for remaining files - process 20 files at a time)*

**General pattern for each batch:**

```bash
# For batch N (files 21*N-20 to 21*N)
sed -n '41,60p' /tmp/models_imports.txt | while read file; do
  echo "Processing: $file"
  sed -i "s|package:PiliPlus/models/common/|package:PiliPlus/models_new/common/|g" "$file"
  sed -i "s|package:PiliPlus/models/\([a-z_]*\)|package:PiliPlus/models_new/\1|g" "$file"
done

fvm flutter analyze --no-pub
git add -A
git commit -m "feat(migrate): update imports batch N (20 files)"
```

Continue until all files in `/tmp/models_imports.txt` are processed.

---

## Task 36: Handle Special Case Imports

**Files:**
- Modify: Files with special import patterns

**Step 1: Find remaining models/ imports**

```bash
grep -r "package:PiliPlus/models/" lib/ --include="*.dart" | grep -v "models_new" | grep -v ".g.dart"
```

**Step 2: Manual review and fix**

For each remaining import:
1. Open the file
2. Check if the model still exists in `models/` or has been migrated
3. Update import path accordingly
4. Handle relative imports if any

**Step 3: Update core model imports**

```bash
# Handle root-level models (model_*.dart)
grep -r "package:PiliPlus/models/model_" lib/ --include="*.dart" | while read line; do
  file=$(echo "$line" | cut -d: -f1)
  echo "Updating core model import in: $file"
  sed -i "s|package:PiliPlus/models/model_|package:PiliPlus/models_new/model_|g" "$file"
done
```

**Step 4: Verify no old imports remain**

```bash
grep -r "package:PiliPlus/models/" lib/ --include="*.dart" | grep -v "models_new" | grep -v ".g.dart" | wc -l
```

Expected: 0 (or minimal list requiring manual fixes)

**Step 5: Commit special cases**

```bash
git add -A
git commit -m "feat(migrate): handle special case imports"
```

---

## Task 37: Update Generated File Imports

**Files:**
- Modify: Files importing `.g.dart` files

**Step 1: Find .g.dart imports**

```bash
grep -r "package:PiliPlus/models/.*\.g\.dart" lib/ --include="*.dart" | grep -v "models_new"
```

**Step 2: Update .g.dart imports**

```bash
grep -rl "package:PiliPlus/models/.*\.g\.dart" lib/ --include="*.dart" | while read file; do
  echo "Processing: $file"
  sed -i "s|package:PiliPlus/models/\([^.]*\)\.g\.dart|package:PiliPlus/models_new/\1.g.dart|g" "$file"
done
```

**Step 3: Verify and commit**

```bash
git add -A
git commit -m "feat(migrate): update generated file imports"
```

---

## Task 38: Regenerate Hive Generated Files

**Files:**
- Modify: `lib/models_new/model_owner.g.dart`
- Modify: `lib/models_new/user/info.g.dart`
- Modify: `lib/models_new/user/stat.g.dart`

**Step 1: Run build runner**

```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

**Step 2: Check if .g.dart files were regenerated**

```bash
ls -la lib/models_new/*.g.dart lib/models_new/user/*.g.dart
```

**Step 3: Verify no conflicts**

```bash
fvm flutter analyze --no-pub
```

**Step 4: Commit regenerated files**

```bash
git add lib/models_new/
git commit -m "chore: regenerate Hive .g.dart files after migration"
```

---

## Task 39: Final Static Analysis

**Files:**
- None (verification)

**Step 1: Run full static analysis**

```bash
fvm flutter analyze
```

Expected: No errors (warnings about unused imports may need cleanup)

**Step 2: Fix any remaining issues**

```bash
# If there are errors, check them
fvm flutter analyze 2>&1 | grep "error •"
```

**Step 3: Run dart format**

```bash
dart format . --output=none --set-exit-if-changed
```

**Step 4: Commit analysis fixes**

```bash
git add -A
git commit -m "chore: fix static analysis issues after migration"
```

---

## Task 40: Update Documentation

**Files:**
- Modify: `CLAUDE.md`
- Modify: `README.md` (if exists)

**Step 1: Update CLAUDE.md**

Find and replace references to models_new:
```bash
# Check for models_new references
grep -n "models_new" CLAUDE.md
```

Update documentation to reflect:
- Single `lib/models/` directory (after rename)
- No mention of `models_new`
- Updated directory structure in architecture section

**Step 2: Verify no models_new references in docs**

```bash
grep -r "models_new" docs/ --include="*.md"
```

**Step 3: Commit doc updates**

```bash
git add CLAUDE.md docs/
git commit -m "docs: update documentation to reflect merged models"
```

---

## Task 41: Safety Checkpoint - Test Build

**Files:**
- None (verification)

**Step 1: Clean build**

```bash
fvm flutter clean
fvm flutter pub get
```

**Step 2: Build APK (or platform of choice)**

```bash
fvm flutter build apk --debug
```

**Step 2.1: Alternative - Build for current platform**

```bash
# If on Linux/macOS/Windows, build for desktop
fvm flutter build linux --debug
# or
fvm flutter build macos --debug
# or
fvm flutter build windows --debug
```

**Step 3: Verify build success**

Expected: Build completes without errors

**Step 4: Update checkpoint**

```bash
cat >> docs/plans/2026-02-05-models-merge-checkpoint.md << 'EOF'
## Pre-Rename Checkpoint
- All imports updated
- Static analysis passes
- Build successful
- Ready for directory rename
EOF

git add docs/plans/2026-02-05-models-merge-checkpoint.md
git commit -m "chore: pre-rename safety checkpoint passed"
```

---

## Task 42: Rename Directories

**Files:**
- Rename: `lib/models/` → `lib/models_old/`
- Rename: `lib/models_new/` → `lib/models/`

**Step 1: Rename old models directory**

```bash
git mv lib/models lib/models_old
```

**Step 2: Rename models_new to models**

```bash
git mv lib/models_new lib/models
```

**Step 3: Verify directory structure**

```bash
ls -la lib/ | grep models
```

Expected:
- `models` (former models_new)
- `models_old` (former models)

**Step 4: Update all imports from models_new to models**

```bash
# Find all files importing models_new
grep -rl "package:PiliPlus/models_new/" lib/ --include="*.dart" > /tmp/models_new_imports.txt
wc -l /tmp/models_new_imports.txt
```

**Step 5: Update imports in batches**

```bash
# Process all files
cat /tmp/models_new_imports.txt | while read file; do
  echo "Processing: $file"
  sed -i "s|package:PiliPlus/models_new/|package:PiliPlus/models/|g" "$file"
done
```

**Step 6: Verify no models_new imports remain**

```bash
grep -r "package:PiliPlus/models_new/" lib/ --include="*.dart" | wc -l
```

Expected: 0

**Step 7: Run static analysis**

```bash
fvm flutter analyze
```

**Step 8: Test build**

```bash
fvm flutter build apk --debug
# or desktop equivalent
```

**Step 9: Commit rename**

```bash
git add -A
git commit -m "refactor: rename models_new to models, old models to models_old"
```

---

## Task 43: Remove Old Models Directory

**Files:**
- Delete: `lib/models_old/`

**Step 1: Final verification - nothing still using old models**

```bash
grep -r "package:PiliPlus/models_old/" lib/ --include="*.dart" | wc -l
grep -r "package:PiliPlus/models/common/" lib/ --include="*.dart" | wc -l
```

Expected: 0 for both

**Step 2: Run tests**

```bash
fvm flutter test
```

Expected: All tests pass

**Step 3: Remove old directory**

```bash
rm -rf lib/models_old
```

**Step 4: Verify directory structure**

```bash
ls -la lib/ | grep models
```

Expected: Only `models` directory exists

**Step 5: Final static analysis**

```bash
fvm flutter analyze
```

**Step 6: Final build test**

```bash
fvm flutter build apk --debug
# or desktop equivalent
```

**Step 7: Update checkpoint**

```bash
cat >> docs/plans/2026-02-05-models-merge-checkpoint.md << 'EOF'
## Merge Complete
- lib/models_old/ removed
- Single lib/models/ directory remains
- All tests pass
- Static analysis clean
- Build successful
EOF

git add docs/plans/2026-02-05-models-merge-checkpoint.md
git commit -m "chore: models merge complete"
```

**Step 8: Final commit**

```bash
git add -A
git commit -m "refactor: remove old models directory, merge complete"
```

---

## Task 44: Create Merge Summary

**Files:**
- Create: `docs/plans/2026-02-05-models-merge-summary.md`

**Step 1: Generate statistics**

```bash
echo "Models Directory Merge Summary" > docs/plans/2026-02-05-models-merge-summary.md
echo "" >> docs/plans/2026-02-05-models-merge-summary.md
echo "## Statistics" >> docs/plans/2026-02-05-models-merge-summary.md
echo "- Date: $(date)" >> docs/plans/2026-02-05-models-merge-summary.md
echo "- Files migrated: 81" >> docs/plans/2026-02-05-models-merge-summary.md
echo "- Imports updated: $(wc -l < /tmp/models_imports.txt)" >> docs/plans/2026-02-05-models-merge-summary.md
echo "- Commits: $(git log --oneline before-models-merge..HEAD | wc -l)" >> docs/plans/2026-02-05-models-merge-summary.md
```

**Step 2: Add directory structure**

```bash
echo "" >> docs/plans/2026-02-05-models-merge-summary.md
echo "## New Directory Structure" >> docs/plans/2026-02-05-models-merge-summary.md
echo "\`\`\`" >> docs/plans/2026-02-05-models-merge-summary.md
tree lib/models/ -L 2 -d >> docs/plans/2026-02-05-models-merge-summary.md
echo "\`\`\`" >> docs/plans/2026-02-05-models-merge-summary.md
```

**Step 3: Add file counts**

```bash
echo "" >> docs/plans/2026-02-05-models-merge-summary.md
echo "## File Counts" >> docs/plans/2026-02-05-models-merge-summary.md
echo "- Total model files: $(find lib/models -name "*.dart" -not -name "*.g.dart" | wc -l)" >> docs/plans/2026-02-05-models-merge-summary.md
echo "- Generated files: $(find lib/models -name "*.g.dart" | wc -l)" >> docs/plans/2026-02-05-models-merge-summary.md
```

**Step 4: Commit summary**

```bash
git add docs/plans/2026-02-05-models-merge-summary.md
git commit -m "docs: add models merge summary"
```

---

## Task 45: Verification and Testing

**Files:**
- None (verification)

**Step 1: Run application**

```bash
fvm flutter run -d <device>
```

**Step 2: Manual testing checklist**

Test critical functionality:
- [ ] App launches successfully
- [ ] Video playback works
- [ ] Login/logout works
- [ ] Search functionality works
- [ ] User profile loads
- [ ] Settings load/save
- [ ] Download manager works
- [ ] Live streaming works

**Step 3: Update checkpoint with test results**

```bash
cat >> docs/plans/2026-02-05-models-merge-checkpoint.md << 'EOF'
## Verification Complete
- Manual testing passed
- All critical features verified
- Ready for production
EOF
```

**Step 4: Final commit**

```bash
git add docs/plans/2026-02-05-models-merge-checkpoint.md
git commit -m "chore: merge verification complete, ready for production"
```

---

## Summary

This implementation plan guides the migration of 81 unique files from `lib/models/` into `lib/models_new/`, followed by renaming and updating 462+ import statements across the codebase.

**Key Success Metrics:**
- ✅ All files migrated without data loss
- ✅ All imports updated and verified
- ✅ Static analysis passes
- ✅ Build succeeds
- ✅ All tests pass
- ✅ Manual testing confirms functionality

**Rollback Strategy:**
If critical issues arise, use `git reset --hard before-models-merge` to revert to pre-merge state.

**Next Steps After Merge:**
1. Monitor for any runtime issues
2. Remove unused imports found during analysis
3. Consider consolidating duplicate models
4. Update any external documentation
