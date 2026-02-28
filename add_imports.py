#!/usr/bin/env python3
"""Add AppRoutes import to files that need it."""

import re
from pathlib import Path

def main():
    """Add imports to all files that use AppRoutes."""
    lib_path = Path('lib')
    count = 0

    for dart_file in lib_path.rglob('*.dart'):
        with open(dart_file, 'r', encoding='utf-8') as f:
            content = f.read()

        # Check if file uses AppRoutes
        if 'AppRoutes.' not in content:
            continue

        # Check if file already has import
        if 'import' in content and 'app_routes.dart' in content:
            continue

        # Add import at the beginning
        import_line = "import 'package:PiliPlus/app/router/app_routes.dart';\n"
        content = import_line + content

        with open(dart_file, 'w', encoding='utf-8') as f:
            f.write(content)

        count += 1
        print(f"Added import to {dart_file}")

    print(f"\nTotal files modified: {count}")

if __name__ == '__main__':
    main()
