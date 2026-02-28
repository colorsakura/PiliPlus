#!/usr/bin/env python3
"""Fix type mismatches in toMemberPage calls."""

import re
import os
from pathlib import Path

def fix_file(file_path):
    """Fix type mismatches in a single file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    changes = 0

    # Pattern 1: toMemberPage(nullableInt) -> toMemberPage(nullableInt!)
    # But we need to add null check instead
    patterns = [
        # Handle int? by adding null check (simple cases)
        (r"PageUtils\.toMemberPage\((\w+\.mid)\)", lambda m: f"PageUtils.toMemberPage({m.group(1)}!)" if "!" in m.group(0) else f"if ({m.group(1)} != null) {{ PageUtils.toMemberPage({m.group(1)}); }}"),
    ]

    # For now, just add ! for int? types (unsafe but matches GetX behavior)
    content = re.sub(
        r"PageUtils\.toMemberPage\(([\w.]+\.mid)\)",
        r"PageUtils.toMemberPage(\1!)",
        content
    )

    # Handle Int64 conversion
    content = re.sub(
        r"PageUtils\.toMemberPage\(([\w.]+\.mid)\)",
        r"PageUtils.toMemberPage(\1.toInt())",
        content
    )

    # Handle String? to int conversion
    content = re.sub(
        r"PageUtils\.toMemberPage\(([\w.]+\.rid)\)",
        r"if (\1 != null) { final mid = int.tryParse(\1); if (mid != null) { PageUtils.toMemberPage(mid); } }",
        content
    )

    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return 1
    return 0

def main():
    """Fix all Dart files."""
    lib_path = Path('lib')
    total_changes = 0

    for dart_file in lib_path.rglob('*.dart'):
        changes = fix_file(dart_file)
        total_changes += changes

    print(f"Total files modified: {total_changes}")

if __name__ == '__main__':
    main()
