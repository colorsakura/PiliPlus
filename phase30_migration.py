#!/usr/bin/env python3
"""Phase 30: Migrate all remaining toDupNamed calls to direct go_router."""

import re
from pathlib import Path

def migrate_file(file_path):
    """Migrate a single file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    changes = 0

    # Pattern 1: Simple one-line routes
    simple_patterns = [
        (r"PageUtils\.toDupNamed\('/searchTrending'\)", r"PageUtils.pushNamed(AppRoutes.searchTrending)"),
        (r"PageUtils\.toDupNamed\('/displayModeSetting'\)", r"PageUtils.pushNamed(AppRoutes.displayModeSetting)"),
        (r"return PageUtils\.toDupNamed\('/loginPage'\);", r"return PageUtils.pushNamed(AppRoutes.loginPage);"),
    ]

    for pattern, replacement in simple_patterns:
        new_content = re.sub(pattern, replacement, content)
        if new_content != content:
            content = new_content
            changes += 1
            print(f"  {file_path}: {pattern[:50]}...")

    # Pattern 2: Multi-line or complex routes - manually handle these
    # Leave /fav, /createFav with .then/.whenComplete for now
    # Leave complex parameterized routes

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
        # Skip page_utils.dart
        if 'page_utils.dart' in str(dart_file):
            continue

        changes = migrate_file(dart_file)
        total_changes += changes

    print(f"\nTotal files modified: {total_changes}")
    print(f"Remaining complex calls need manual migration")

if __name__ == '__main__':
    main()
