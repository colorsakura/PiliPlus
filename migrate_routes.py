#!/usr/bin/env python3
"""Migrate remaining toDupNamed calls to go_router."""

import re
import os
from pathlib import Path

# Define replacement patterns
PATTERNS = [
    # /member routes with various variable patterns
    (r"PageUtils\.toDupNamed\('/member\?mid=\${([^}]+)}'\)", r"PageUtils.toMemberPage(\1)"),

    # /member routes with dot notation (e.g., item.mid, videoItem.owner.mid)
    (r"PageUtils\.toDupNamed\('/member\?mid=\$([a-zA-Z_][a-zA-Z0-9_.]*)'\)", r"PageUtils.toMemberPage(\1)"),

    # Simple routes
    (r"PageUtils\.toDupNamed\('/webview'", r"PageUtils.pushNamed(AppRoutes.webview"),
    (r"PageUtils\.toDupNamed\('/dynamicDetail'", r"PageUtils.pushNamed(AppRoutes.dynamicDetail"),
    (r"PageUtils\.toDupNamed\('/subDetail'", r"PageUtils.pushNamed(AppRoutes.subDetail"),
    (r"PageUtils\.toDupNamed\('/followed'", r"PageUtils.pushNamed(AppRoutes.followed"),
    (r"PageUtils\.toDupNamed\('/sameFollowing'", r"PageUtils.pushNamed(AppRoutes.sameFollowing"),
    (r"PageUtils\.toDupNamed\('/memberSearch'", r"PageUtils.pushNamed(AppRoutes.memberSearch)"),
    (r"PageUtils\.toDupNamed\('/about'", r"PageUtils.pushNamed(AppRoutes.about)"),
    (r"PageUtils\.toDupNamed\('/hot'", r"PageUtils.pushNamed(AppRoutes.hot)"),
    (r"PageUtils\.toDupNamed\('/home'", r"PageUtils.pushNamed(AppRoutes.home)"),
    (r"PageUtils\.toDupNamed\('/dynamics'", r"PageUtils.pushNamed(AppRoutes.dynamics)"),
    (r"PageUtils\.toDupNamed\('/fan'", r"PageUtils.pushNamed(AppRoutes.fan)"),
]

def migrate_file(file_path):
    """Migrate a single file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    changes = 0

    # Apply single-line patterns first
    for pattern, replacement in PATTERNS:
        new_content = re.sub(pattern, replacement, content)
        if new_content != content:
            count = len(re.findall(pattern, content))
            changes += count
            content = new_content
            print(f"  {file_path}: Replaced {count} occurrences of {pattern[:50]}...")

    # Apply multi-line patterns
    # Replace toDupNamed('/webview', with pushNamed(AppRoutes.webview,
    content = re.sub(
        r"PageUtils\.toDupNamed\(\s*'/webview',\s*",
        "PageUtils.pushNamed(AppRoutes.webview, ",
        content
    )

    # Replace toDupNamed('/dynamicDetail', with pushNamed(AppRoutes.dynamicDetail,
    content = re.sub(
        r"PageUtils\.toDupNamed\(\s*'/dynamicDetail',\s*",
        "PageUtils.pushNamed(AppRoutes.dynamicDetail, ",
        content
    )

    # Replace toDupNamed('/subDetail', with pushNamed(AppRoutes.subDetail,
    content = re.sub(
        r"PageUtils\.toDupNamed\(\s*'/subDetail',\s*",
        "PageUtils.pushNamed(AppRoutes.subDetail, ",
        content
    )

    # Replace toDupNamed('/followed', with pushNamed(AppRoutes.followed,
    content = re.sub(
        r"PageUtils\.toDupNamed\(\s*'/followed',\s*",
        "PageUtils.pushNamed(AppRoutes.followed, ",
        content
    )

    # Replace toDupNamed('/sameFollowing', with pushNamed(AppRoutes.sameFollowing,
    content = re.sub(
        r"PageUtils\.toDupNamed\(\s*'/sameFollowing',\s*",
        "PageUtils.pushNamed(AppRoutes.sameFollowing, ",
        content
    )

    # Replace toDupNamed('/memberSearch', with pushNamed(AppRoutes.memberSearch,
    content = re.sub(
        r"PageUtils\.toDupNamed\(\s*'/memberSearch',\s*",
        "PageUtils.pushNamed(AppRoutes.memberSearch, ",
        content
    )

    # Replace toDupNamed('/about', with pushNamed(AppRoutes.about,
    content = re.sub(
        r"PageUtils\.toDupNamed\(\s*'/about',\s*",
        "PageUtils.pushNamed(AppRoutes.about, ",
        content
    )

    # Replace toDupNamed('/hot', with pushNamed(AppRoutes.hot,
    content = re.sub(
        r"PageUtils\.toDupNamed\(\s*'/hot',\s*",
        "PageUtils.pushNamed(AppRoutes.hot, ",
        content
    )

    # Replace toDupNamed('/home', with pushNamed(AppRoutes.home,
    content = re.sub(
        r"PageUtils\.toDupNamed\(\s*'/home',\s*",
        "PageUtils.pushNamed(AppRoutes.home, ",
        content
    )

    # Replace toDupNamed('/dynamics', with pushNamed(AppRoutes.dynamics,
    content = re.sub(
        r"PageUtils\.toDupNamed\(\s*'/dynamics',\s*",
        "PageUtils.pushNamed(AppRoutes.dynamics, ",
        content
    )

    # Replace toDupNamed('/fan', with pushNamed(AppRoutes.fan,
    content = re.sub(
        r"PageUtils\.toDupNamed\(\s*'/fan',\s*",
        "PageUtils.pushNamed(AppRoutes.fan, ",
        content
    )

    # Replace toDupNamed('/searchResult', with pushNamed(AppRoutes.searchResult,
    content = re.sub(
        r"PageUtils\.toDupNamed\(\s*'/searchResult',\s*",
        "PageUtils.pushNamed(AppRoutes.searchResult, ",
        content
    )

    # Replace toDupNamed('/articlePage', with pushNamed(AppRoutes.articlePage,
    content = re.sub(
        r"PageUtils\.toDupNamed\(\s*'/articlePage',\s*",
        "PageUtils.pushNamed(AppRoutes.articlePage, ",
        content
    )

    # Replace toDupNamed('/favDetail', with pushNamed(AppRoutes.favDetail,
    content = re.sub(
        r"PageUtils\.toDupNamed\(\s*'/favDetail',\s*",
        "PageUtils.pushNamed(AppRoutes.favDetail, ",
        content
    )

    # Replace toDupNamed('/dynTopic', with pushNamed(AppRoutes.dynTopic,
    content = re.sub(
        r"PageUtils\.toDupNamed\(\s*'/dynTopic',\s*",
        "PageUtils.pushNamed(AppRoutes.dynTopic, ",
        content
    )

    # Replace toDupNamed('/musicDetail', with pushNamed(AppRoutes.musicDetail,
    content = re.sub(
        r"PageUtils\.toDupNamed\(\s*'/musicDetail',\s*",
        "PageUtils.pushNamed(AppRoutes.musicDetail, ",
        content
    )

    # Replace toDupNamed('/videoV', with pushNamed(AppRoutes.video,
    content = re.sub(
        r"PageUtils\.toDupNamed\(\s*'/videoV',\s*",
        "PageUtils.pushNamed(AppRoutes.video, ",
        content
    )

    # Replace toDupNamed('/upowerRank', with pushNamed(AppRoutes.upowerRank,
    content = re.sub(
        r"PageUtils\.toDupNamed\(\s*'/upowerRank',\s*",
        "PageUtils.pushNamed(AppRoutes.upowerRank, ",
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
        total_changes += changes

    print(f"\nTotal changes: {total_changes}")

if __name__ == '__main__':
    main()
