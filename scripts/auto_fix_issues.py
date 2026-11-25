#!/usr/bin/env python3
"""Conservative Flutter maintenance: backup, SDK fixes, format, analyze."""
import argparse
import datetime
import pathlib
import shutil
import subprocess
import sys
import tempfile

SAFE_CODES = ('unused_import', 'duplicate_import', 'unnecessary_import',
              'unnecessary_new', 'unnecessary_const', 'prefer_const_constructors',
              'prefer_const_literals_to_create_immutables', 'unnecessary_this',
              'prefer_is_empty', 'prefer_is_not_empty', 'unnecessary_string_interpolations',
              'unnecessary_brace_in_string_interps', 'sort_child_properties_last')

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--project', default='.')
    p.add_argument('--dry-run', action='store_true')
    p.add_argument('--test', action='store_true')
    p.add_argument('--all-fixes', action='store_true', help='Allow all SDK bulk fixes; review diff carefully')
    a = p.parse_args()
    root = pathlib.Path(a.project).resolve()
    if not (root/'pubspec.yaml').is_file() or not (root/'lib').is_dir():
        p.error('Select a Flutter project root')
    flutter = shutil.which('flutter')
    dart = shutil.which('dart')
    if not dart and flutter:
        candidate = pathlib.Path(flutter).resolve().with_name('dart')
        if candidate.is_file(): dart = str(candidate)
    if not flutter or not dart: p.error('Flutter and Dart SDK must be installed and on PATH')
    dirs = [x for x in ('lib','test','integration_test','bin','tool') if (root/x).is_dir()]
    backup = None
    def run(*cmd):
        print('\n>>>', ' '.join(cmd), flush=True)
        return subprocess.run(cmd, cwd=root, check=False).returncode
    if a.dry_run:
        return run(dart,'fix','--dry-run', *([] if a.all_fixes else ['--code='+','.join(SAFE_CODES)]))
    backup = pathlib.Path(tempfile.mkdtemp(prefix='flutter-fix-'+datetime.datetime.now().strftime('%Y%m%d-%H%M%S')+'-'))
    # Snapshot all project Dart sources, including local packages; never follow symlinks.
    excluded = {'.git','.dart_tool','build','.gradle','.idea','node_modules','.notneeded','Pods','.symlinks'}
    import os
    for base, subdirs, files in os.walk(root, followlinks=False):
        subdirs[:] = [d for d in subdirs if d not in excluded and not d.startswith('.')]
        for name in files:
            src = pathlib.Path(base)/name
            if src.suffix == '.dart' and not src.is_symlink():
                dst = backup/src.relative_to(root)
                dst.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(src,dst)
    print('Source backup:', backup, flush=True)
    try:
        if run(flutter,'pub','get'): return 1
        if run(dart,'fix','--apply', *([] if a.all_fixes else ['--code='+','.join(SAFE_CODES)])): return 1
        # Formatting is deliberately the final source-changing operation.
        if run(dart,'format',*dirs): return 1
        result = run(flutter,'analyze','--no-pub')
        if a.test:
            result = run(flutter,'test','--no-pub') or result
        print('\nRuntime review: inspect JuzListWidget.build and QuranController.fetchJuzListData.')
        print('Move initial fetch to initState with a mounted post-frame callback if needed; do not fetch on every build.')
        print('For StatelessWidget/StatefulWidget cast errors after hot reload, stop and restart the app.')
        print('Review git diff before committing. Remaining analyzer/runtime issues need manual review.')
        return result
    finally:
        print('Original Dart sources preserved at:', backup)
        print('Dependency resolution may also update pubspec.lock; review separately.')

if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, KeyboardInterrupt) as exc:
        print(f'Interrupted or failed: {exc}', file=sys.stderr)
        sys.exit(1)
