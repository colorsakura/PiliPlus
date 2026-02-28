#!/usr/bin/env python3
"""Phase 28: Migrate remaining toDupNamed calls to direct go_router usage."""

import re
from pathlib import Path

def migrate_file(file_path):
    """Migrate a single file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content

    # Pattern 1: Simple routes with ??.then() - these now work with pushNamed
    patterns = [
        # /createFav with .then()
        (
            r"PageUtils\.toDupNamed\('/createFav'\)\?\.then\(",
            r"PageUtils.pushNamed(AppRoutes.createFav).then("
        ),
        # /fav with .whenComplete
        (
            r"PageUtils\.toDupNamed\('/fav'\)\?\.whenComplete\(",
            r"PageUtils.pushNamed(AppRoutes.fav).whenComplete("
        ),
        # /loginPage with return
        (
            r"return PageUtils\.toDupNamed\('/loginPage'\);",
            r"return PageUtils.pushNamed(AppRoutes.loginPage);"
        ),
        # /searchTrending
        (
            r"PageUtils\.toDupNamed\('/searchTrending'\)",
            r"PageUtils.pushNamed(AppRoutes.searchTrending)"
        ),
        # /displayModeSetting
        (
            r"PageUtils\.toDupNamed\('/displayModeSetting'\)",
            r"PageUtils.pushNamed(AppRoutes.displayModeSetting)"
        ),
    ]

    for pattern, replacement in patterns:
        new_content = re.sub(pattern, replacement, content)
        if new_content != content:
            content = new_content
            print(f"  {file_path}: {pattern[:50]}...")

    # Pattern 2: /search with parameters (multi-line)
    # Handle later manually

    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return 1
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

if __name__ == '__main__':
    main()
