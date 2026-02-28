#!/usr/bin/env python3
"""Phase 29: Replace Get.back() with PageUtils.pop()."""

import re
from pathlib import Path

def has_pageutils_import(file_path):
    """Check if file already imports PageUtils."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
        return "import 'package:PiliPlus/utils/page_utils.dart'" in content or \
               'import "package:PiliPlus/utils/page_utils.dart"' in content

def add_pageutils_import(file_path):
    """Add PageUtils import to file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find the last import line
    lines = content.split('\n')
    import_end_idx = 0
    for i, line in enumerate(lines):
        if line.strip().startswith("import '") or line.strip().startswith('import "'):
            import_end_idx = i

    # Insert PageUtils import after the last import
    if import_end_idx > 0:
        lines.insert(import_end_idx + 1, "import 'package:PiliPlus/utils/page_utils.dart';")

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))

def migrate_file(file_path):
    """Migrate a single file."""
    # Skip if already has PageUtils import or no Get.back()
    if not has_pageutils_import(file_path):
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        if 'Get.back(' not in content:
            return 0
        add_pageutils_import(file_path)
        print(f"  Added PageUtils import to {file_path}")

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    changes = 0

    # Pattern 1: Get.back(result: xxx) → PageUtils.pop(xxx)
    pattern1 = r"Get\.back\(result:\s*([^)]+)\)"
    replacement1 = r"PageUtils.pop(\1)"
    matches1 = len(re.findall(pattern1, content))
    if matches1 > 0:
        content = re.sub(pattern1, replacement1, content)
        changes += matches1
        print(f"  {file_path}: Replaced {matches1} Get.back(result: xxx)")

    # Pattern 2: Get.back() → PageUtils.pop()
    pattern2 = r"Get\.back\(\)"
    replacement2 = "PageUtils.pop()"
    matches2 = len(re.findall(pattern2, content)) - len(re.findall(pattern1, content))
    if matches2 > 0:
        content = re.sub(pattern2, replacement2, content)
        changes += matches2
        print(f"  {file_path}: Replaced {matches2} Get.back()")

    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return changes
    return 0

def main():
    """Migrate all Dart files."""
    lib_path = Path('lib')
    total_changes = 0
    total_files = 0

    for dart_file in lib_path.rglob('*.dart'):
        # Skip page_utils.dart
        if 'page_utils.dart' in str(dart_file):
            continue

        changes = migrate_file(dart_file)
        if changes > 0:
            total_files += 1
            total_changes += changes

    print(f"\nTotal files modified: {total_files}")
    print(f"Total Get.back() calls replaced: {total_changes}")

if __name__ == '__main__':
    main()
