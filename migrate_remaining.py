#!/usr/bin/env python3
"""Migrate remaining toDupNamed calls to go_router."""

import re
from pathlib import Path

def migrate_file(file_path):
    """Migrate a single file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    changes = 0

    # Pattern 1: Simple routes without return value needed
    simple_routes = {
        "'/search'": "AppRoutes.search",
        "'/setting'": "AppRoutes.setting",
        "'/webview'": "AppRoutes.webview",
        "'/dynamics'": "AppRoutes.dynamics",
        "'/follow'": "AppRoutes.follow",
        "'/followed'": "AppRoutes.followed",
        "'/sameFollowing'": "AppRoutes.sameFollowing",
        "'/memberSearch'": "AppRoutes.memberSearch",
        "'/fan'": "AppRoutes.fan",
    }

    for old_route, new_route in simple_routes.items():
        # Replace simple calls without parameters or return value
        pattern = rf"PageUtils\.toDupNamed\(\s*{old_route}\s*\)"
        if re.search(pattern, content) and ".whenComplete(" not in content[max(0, content.find(old_route)-200):content.find(old_route)+200]:
            content = re.sub(pattern, f"PageUtils.pushNamed({new_route})", content)
            changes += 1

    # Pattern 2: Routes with parameters (single line)
    content = re.sub(
        r"PageUtils\.toDupNamed\(\s*'/search',\s*parameters:\s*({[^}]+})\s*\)",
        r"PageUtils.pushNamed(AppRoutes.search, parameters: \1)",
        content
    )

    # Pattern 3: Multi-line /search with parameters
    content = re.sub(
        r"PageUtils\.toDupNamed\(\s*'/search',\s*parameters:\s*({[\s\S]*?})\s*\)",
        r"PageUtils.pushNamed(AppRoutes.search, parameters: \1)",
        content
    )

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
        changes = migrate_file(dart_file)
        if changes > 0:
            print(f"Migrated {changes} patterns in {dart_file}")
            total_changes += changes

    print(f"\nTotal changes: {total_changes}")

if __name__ == '__main__':
    main()
