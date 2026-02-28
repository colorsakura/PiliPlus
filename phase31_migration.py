#!/usr/bin/env python3
"""Phase 31: Replace remaining Get.toNamed calls with go_router."""

import re
from pathlib import Path

def migrate_file(file_path):
    """Migrate a single file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    changes = 0

    # Pattern 1: Simple Get.toNamed routes that have AppRoutes constants
    patterns = [
        (r"Get\.toNamed\('/search'\)", r"PageUtils.goNamed(AppRoutes.search)"),
        (r"Get\.toNamed\('/whisper'\)", r"PageUtils.goNamed(AppRoutes.whisper)"),
    ]

    for pattern, replacement in patterns:
        new_content = re.sub(pattern, replacement, content)
        if new_content != content:
            content = new_content
            changes += 1
            print(f"  {file_path}: {pattern}")

    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return changes
    return 0

def main():
    """Migrate all Dart files."""
    lib_path = Path('lib')
    total_changes = 0

    for dart_file in lib_path.rglob('*.dart'):
        # Skip specific files
        if any(x in str(dart_file) for x in ['page_utils.dart', 'three_dot_ext.dart', 'reply_utils.dart', 'request_utils.dart']):
            continue

        changes = migrate_file(dart_file)
        total_changes += changes

    print(f"\nTotal files modified: {total_changes}")

if __name__ == '__main__':
    main()
