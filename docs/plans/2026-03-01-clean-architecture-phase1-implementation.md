# Clean Architecture Migration - Phase 1: Core Infrastructure

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Complete migration of core infrastructure from `lib/http/` to establish clean architecture foundation

**Architecture:** Move infrastructure files (HTTP client, interceptors, constants, models) from `lib/http/` to their proper clean architecture locations in `lib/core/` and `lib/shared/`

**Tech Stack:** Flutter 3.41.2, Dart 3.10+, Dio 5.9.1

---

## Prerequisites

**Before starting:**
1. Read `docs/CLEAN_ARCHITECTURE_MIGRATION.md` for context
2. Read `docs/plans/2026-03-01-clean-architecture-migration-design.md` for full design
3. Ensure `flutter analyze` currently passes
4. Commit any uncommitted work

**Setup verification:**
```bash
# Verify we're on main branch
git branch --show-current

# Check current flutter analyze status
flutter analyze

# Verify lib/http/ exists with these files
ls -la lib/http/*.dart
```

---

## Task 1: Verify and Document Current State

**Files:**
- Reference: `lib/http/init.dart`
- Reference: `lib/core/network/http_client.dart`

**Step 1: Check if http/init.dart is still referenced**

Search for imports of the old init file:
```bash
grep -r "package:PiliPlus/http/init.dart" lib/ --include="*.dart" | wc -l
```

Expected: Number of files (if any) still importing from `lib/http/init.dart`

**Step 2: Check existing core/network/http_client.dart**

Read the existing HTTP client:
```bash
cat lib/core/network/http_client.dart | head -50
```

Expected: File exists with HttpClient class

**Step 3: Create verification document**

Create `docs/plans/phase1-verification.md`:
```bash
cat > docs/plans/phase1-verification.md << 'EOF'
# Phase 1 Initial State Verification

## HTTP Client Status
- lib/http/init.dart references: [COUNT from step 1]
- lib/core/network/http_client.dart: [EXISTS or NOT]
- Migration complete: [YES/NO]

## Files to Migrate
1. loading_state.dart
2. retry_interceptor.dart
3. logging_interceptor.dart
4. ua_type.dart
EOF
```

**Step 4: Commit verification document**

```bash
git add docs/plans/phase1-verification.md
git commit -m "docs: add phase 1 initial state verification"
```

---

## Task 2: Migrate LoadingState to Shared Layer

**Files:**
- Move: `lib/http/loading_state.dart` → `lib/shared/data/models/loading_state.dart`
- Modify: All files importing `package:PiliPlus/http/loading_state.dart`

**Step 1: Create target directory**

```bash
mkdir -p lib/shared/data/models
```

Expected: Directory created with no output

**Step 2: Copy loading_state.dart to new location**

```bash
cp lib/http/loading_state.dart lib/shared/data/models/loading_state.dart
```

Expected: File copied with no output

**Step 3: Verify the file was copied successfully**

```bash
wc -l lib/http/loading_state.dart lib/shared/data/models/loading_state.dart
```

Expected: Both files show same line count (should be ~100 lines)

**Step 4: Find all files importing old location**

```bash
grep -rl "package:PiliPlus/http/loading_state.dart" lib/ --include="*.dart" > /tmp/loading_state_imports.txt
cat /tmp/loading_state_imports.txt
```

Expected: List of files (count them)

**Step 5: Update imports in all files**

For each file in `/tmp/loading_state_imports.txt`, update the import:
```bash
while IFS= read -r file; do
  sed -i "s|package:PiliPlus/http/loading_state.dart|package:PiliPlus/shared/data/models/loading_state.dart|g" "$file"
done < /tmp/loading_state_imports.txt
```

Expected: No output (files modified in place)

**Step 6: Verify imports were updated**

```bash
grep -r "package:PiliPlus/http/loading_state.dart" lib/ --include="*.dart" | wc -l
```

Expected: 0 (no old imports remaining)

**Step 7: Run flutter analyze**

```bash
flutter analyze
```

Expected: No errors related to LoadingState imports

**Step 8: Test app on Linux**

```bash
timeout 30 flutter run -d linux 2>&1 | head -20
```

Expected: App starts without LoadingState import errors

**Step 9: Commit the migration**

```bash
git add lib/shared/data/models/loading_state.dart
git add -u lib/
git commit -m "refactor: migrate LoadingState to shared/data/models

- Move lib/http/loading_state.dart → lib/shared/data/models/loading_state.dart
- Update all imports across codebase
- Part of clean architecture migration (Phase 1)
"
```

**Step 10: Remove old file**

```bash
rm lib/http/loading_state.dart
```

Expected: File deleted with no output

**Step 11: Commit removal**

```bash
git add -u lib/
git commit -m "refactor: remove old lib/http/loading_state.dart

All references migrated to shared/data/models/loading_state.dart
"
```

---

## Task 3: Migrate Retry Interceptor

**Files:**
- Move: `lib/http/retry_interceptor.dart` → `lib/core/network/http_interceptors/retry_interceptor.dart`
- Modify: Files importing old location
- Modify: `lib/core/network/http_client.dart` (if it imports this)

**Step 1: Create target directory**

```bash
mkdir -p lib/core/network/http_interceptors
```

Expected: Directory created (may already exist)

**Step 2: Copy retry_interceptor.dart to new location**

```bash
cp lib/http/retry_interceptor.dart lib/core/network/http_interceptors/retry_interceptor.dart
```

Expected: File copied

**Step 3: Find files importing old location**

```bash
grep -rl "package:PiliPlus/http/retry_interceptor.dart" lib/ --include="*.dart" > /tmp/retry_imports.txt
cat /tmp/retry_imports.txt
```

Expected: List includes `lib/core/network/http_client.dart` and possibly others

**Step 4: Update imports in all files**

```bash
while IFS= read -r file; do
  sed -i "s|package:PiliPlus/http/retry_interceptor.dart|package:PiliPlus/core/network/http_interceptors/retry_interceptor.dart|g" "$file"
done < /tmp/retry_imports.txt
```

Expected: No output

**Step 5: Verify imports updated**

```bash
grep -r "package:PiliPlus/http/retry_interceptor.dart" lib/ --include="*.dart" | wc -l
```

Expected: 0

**Step 6: Run flutter analyze**

```bash
flutter analyze
```

Expected: No errors

**Step 7: Test on Linux**

```bash
timeout 30 flutter run -d linux 2>&1 | head -20
```

Expected: App runs without retry interceptor import errors

**Step 8: Commit migration**

```bash
git add lib/core/network/http_interceptors/retry_interceptor.dart
git add -u lib/
git commit -m "refactor: migrate RetryInterceptor to core/network/http_interceptors

- Move lib/http/retry_interceptor.dart → lib/core/network/http_interceptors/
- Update all imports
- Part of clean architecture migration (Phase 1)
"
```

**Step 9: Remove old file**

```bash
rm lib/http/retry_interceptor.dart
git add -u lib/
git commit -m "refactor: remove old lib/http/retry_interceptor.dart"
```

---

## Task 4: Migrate Logging Interceptor

**Files:**
- Move: `lib/http/logging_interceptor.dart` → `lib/core/network/http_interceptors/logging_interceptor.dart`
- Modify: Files importing old location

**Step 1: Copy logging_interceptor.dart to new location**

```bash
cp lib/http/logging_interceptor.dart lib/core/network/http_interceptors/logging_interceptor.dart
```

Expected: File copied

**Step 2: Find files importing old location**

```bash
grep -rl "package:PiliPlus/http/logging_interceptor.dart" lib/ --include="*.dart" > /tmp/logging_imports.txt
cat /tmp/logging_imports.txt
```

Expected: List of files

**Step 3: Update imports in all files**

```bash
while IFS= read -r file; do
  sed -i "s|package:PiliPlus/http/logging_interceptor.dart|package:PiliPlus/core/network/http_interceptors/logging_interceptor.dart|g" "$file"
done < /tmp/logging_imports.txt
```

Expected: No output

**Step 4: Verify imports updated**

```bash
grep -r "package:PiliPlus/http/logging_interceptor.dart" lib/ --include="*.dart" | wc -l
```

Expected: 0

**Step 5: Run flutter analyze**

```bash
flutter analyze
```

Expected: No errors

**Step 6: Test on Linux**

```bash
timeout 30 flutter run -d linux 2>&1 | head -20
```

Expected: App runs without errors

**Step 7: Commit migration**

```bash
git add lib/core/network/http_interceptors/logging_interceptor.dart
git add -u lib/
git commit -m "refactor: migrate LoggingInterceptor to core/network/http_interceptors

- Move lib/http/logging_interceptor.dart → lib/core/network/http_interceptors/
- Update all imports
- Part of clean architecture migration (Phase 1)
"
```

**Step 8: Remove old file**

```bash
rm lib/http/logging_interceptor.dart
git add -u lib/
git commit -m "refactor: remove old lib/http/logging_interceptor.dart"
```

---

## Task 5: Migrate UA Type Constants

**Files:**
- Move: `lib/http/ua_type.dart` → `lib/core/constants/ua_constants.dart`
- Modify: Files importing old location

**Step 1: Copy ua_type.dart to new location**

```bash
cp lib/http/ua_type.dart lib/core/constants/ua_constants.dart
```

Expected: File copied

**Step 2: Find files importing old location**

```bash
grep -rl "package:PiliPlus/http/ua_type.dart" lib/ --include="*.dart" > /tmp/ua_imports.txt
cat /tmp/ua_imports.txt
```

Expected: List of files

**Step 3: Update imports in all files**

```bash
while IFS= read -r file; do
  sed -i "s|package:PiliPlus/http/ua_type.dart|package:PiliPlus/core/constants/ua_constants.dart|g" "$file"
done < /tmp/ua_imports.txt
```

Expected: No output

**Step 4: Verify imports updated**

```bash
grep -r "package:PiliPlus/http/ua_type.dart" lib/ --include="*.dart" | wc -l
```

Expected: 0

**Step 5: Run flutter analyze**

```bash
flutter analyze
```

Expected: No errors

**Step 6: Test on Linux**

```bash
timeout 30 flutter run -d linux 2>&1 | head -20
```

Expected: App runs without errors

**Step 7: Commit migration**

```bash
git add lib/core/constants/ua_constants.dart
git add -u lib/
git commit -m "refactor: migrate UA type constants to core/constants

- Move lib/http/ua_type.dart → lib/core/constants/ua_constants.dart
- Update all imports
- Part of clean architecture migration (Phase 1)
"
```

**Step 8: Remove old file**

```bash
rm lib/http/ua_type.dart
git add -u lib/
git commit -m "refactor: remove old lib/http/ua_type.dart"
```

---

## Task 6: Handle http/init.dart (HTTP Client)

**Files:**
- Reference: `lib/http/init.dart`
- Reference: `lib/core/network/http_client.dart`

**Step 1: Check if init.dart still exists**

```bash
ls -la lib/http/init.dart 2>&1
```

Expected: Either "File exists" or "No such file or directory"

**Case A: If init.dart still exists**

**Step 2a: Find all references to init.dart**

```bash
grep -rl "package:PiliPlus/http/init.dart" lib/ --include="*.dart" > /tmp/init_imports.txt
cat /tmp/init_imports.txt
```

Expected: List of files (or empty if none)

**Step 3a: If references exist, check what they import**

```bash
head -20 lib/http/init.dart
```

Expected: See what classes/functions are exported

**Step 4a: For each exported class, find its new location**

Check if `lib/core/network/http_client.dart` has equivalent:
```bash
grep -E "class (HttpClient|Request|Dio)" lib/core/network/http_client.dart
```

Expected: HttpClient class exists

**Step 5a: Update imports to use new location**

```bash
# If lib/http/init.dart exports HttpClient, replace imports:
while IFS= read -r file; do
  sed -i "s|package:PiliPlus/http/init.dart|package:PiliPlus/core/network/http_client.dart|g" "$file"
done < /tmp/init_imports.txt
```

Expected: No output

**Step 6a: Run flutter analyze**

```bash
flutter analyze
```

Expected: No errors (may need manual fixes if API differs)

**Step 7a: Test on Linux**

```bash
timeout 30 flutter run -d linux 2>&1 | head -20
```

Expected: App runs without errors

**Step 8a: Commit changes**

```bash
git add -u lib/
git commit -m "refactor: update imports from http/init.dart to core/network/http_client.dart

Migrate remaining references to use new HTTP client location
"
```

**Step 9a: Remove init.dart**

```bash
rm lib/http/init.dart
git add -u lib/
git commit -m "refactor: remove old lib/http/init.dart

All functionality migrated to lib/core/network/http_client.dart
"
```

**Case B: If init.dart already migrated**

**Step 2b: Document that migration is complete**

```bash
echo "✅ http/init.dart already migrated to core/network/http_client.dart" >> docs/plans/phase1-verification.md
```

---

## Task 7: Final Verification and Cleanup

**Files:**
- Create: `docs/plans/phase1-completion.md`
- Reference: `lib/http/` directory

**Step 1: Check remaining files in lib/http/**

```bash
ls -1 lib/http/*.dart | wc -l
```

Expected: Only business API files remain (video.dart, login.dart, etc.), no infrastructure files

**Step 2: Verify no infrastructure files remain**

```bash
ls -1 lib/http/*.dart | grep -E "(init|loading_state|retry_interceptor|logging_interceptor|ua_type)" || echo "✅ No infrastructure files remaining"
```

Expected: "No infrastructure files remaining"

**Step 3: Run full flutter analyze**

```bash
flutter analyze 2>&1 | tee /tmp/flutter_analyze_output.txt
```

Expected: No errors, only warnings/info

**Step 4: Verify no errors**

```bash
grep -E "error|Error" /tmp/flutter_analyze_output.txt | wc -l
```

Expected: 0

**Step 5: Test on Linux for 30 seconds**

```bash
timeout 30 flutter run -d linux 2>&1 | tee /tmp/linux_run_output.txt
```

Expected: App starts and runs for 30 seconds without crashes

**Step 6: Verify app ran successfully**

```bash
grep -E "error|Error|exception|Exception" /tmp/linux_run_output.txt | wc -l
```

Expected: 0 or minimal non-critical errors

**Step 7: Create completion report**

```bash
cat > docs/plans/phase1-completion.md << 'EOF'
# Phase 1 Completion Report

## Date
$(date +%Y-%m-%d)

## Migrated Files

### ✅ Completed
1. loading_state.dart → lib/shared/data/models/loading_state.dart
2. retry_interceptor.dart → lib/core/network/http_interceptors/retry_interceptor.dart
3. logging_interceptor.dart → lib/core/network/http_interceptors/logging_interceptor.dart
4. ua_type.dart → lib/core/constants/ua_constants.dart
5. init.dart → lib/core/network/http_client.dart (if existed)

## Verification Results

### Flutter Analyze
- Status: PASSED
- Errors: 0
- Warnings: [COUNT from step 4]

### Linux Run Test
- Status: PASSED
- Duration: 30 seconds
- Errors: [COUNT from step 6]

## Remaining in lib/http/
Business API files (22 files to be migrated in Phase 2-4):
- video.dart
- login.dart
- live.dart
- search.dart
- [and 18 more...]

## Next Steps
Proceed to Phase 2: High-Traffic API Migration
EOF
```

Expected: File created

**Step 8: Commit completion report**

```bash
git add docs/plans/phase1-completion.md
git commit -m "docs: add Phase 1 completion report

All core infrastructure files migrated from lib/http/
Ready to proceed to Phase 2: High-Traffic API Migration
"
```

**Step 9: Create summary commit**

```bash
git add docs/plans/
git commit -m "docs: complete Phase 1 documentation

- Initial verification report
- Completion report with metrics
- Ready for Phase 2 execution
"
```

---

## Success Criteria

Phase 1 is complete when:

- [x] All infrastructure files removed from `lib/http/`
- [ ] `flutter analyze` passes with zero errors
- [ ] App runs successfully on Linux (30 seconds)
- [ ] Only business API files remain in `lib/http/`
- [ ] Documentation updated with completion report
- [ ] All changes committed to git

---

## Rollback Procedure

If critical issues arise:

```bash
# Revert to pre-phase 1 state
git log --oneline | grep "refactor: migrate"  # Find commits
git revert <commit-hash>...<commit-hash>  # Revert range

# Or reset entirely (WARNING: destructive)
git reflog  # Find pre-phase1 commit
git reset --hard <pre-phase1-commit>
```

---

## Notes

### Key Patterns Established

1. **Copy first, delete later** - Maintains ability to rollback
2. **Update imports before removing old files** - Ensures no broken references
3. **Test after each file migration** - Catch issues early
4. **Commit frequently** - Easy rollback to any point

### Common Commands Reference

```bash
# Find all files importing a specific path
grep -rl "package:PiliPlus/http/FILE.dart" lib/ --include="*.dart"

# Replace imports across multiple files
sed -i "s|old/path|new/path|g" file.dart

# Count lines of code
wc -l file.dart

# Run flutter analyze
flutter analyze

# Test on Linux with timeout
timeout 30 flutter run -d linux

# Commit changes
git add files...
git commit -m "message"
```

---

**Phase 1 Estimated Time:** 8-10 hours
**Actual Time:** [Fill in during execution]
**Blocks Phase 2:** YES - Must complete before migrating business API files
