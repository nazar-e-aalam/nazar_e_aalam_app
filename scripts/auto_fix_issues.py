#!/usr/bin/env python3
"""Explicit, narrow Flutter maintenance. No SDK bulk fixes or pub get."""
import argparse
import difflib
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

IMPORT = re.compile(rb"(?m)^([ \t]*import[ \t]+)(['\"])package:material_ui/material_ui\.dart\2([ \t]*;[ \t]*\r?)$")
IGNORE = re.compile(rb'(?m)^\s*//\s*ignore_for_file:[^\r\n]*\bdeprecated_member_use\b')
GENERATED = ('.g.dart', '.freezed.dart', '.mocks.dart', '.gr.dart')

def patch(data, migrate=False, suppress=False):
    if not migrate:
        return data
    updated = IMPORT.sub(lambda m: m[1]+m[2]+b'package:flutter/material.dart'+m[2]+m[3], data)
    if updated != data and suppress and not IGNORE.search(updated):
        bom = b'\xef\xbb\xbf' if updated.startswith(b'\xef\xbb\xbf') else b''
        nl = b'\r\n' if b'\r\n' in updated else b'\n'
        updated = bom+b'// ignore_for_file: deprecated_member_use'+nl+nl+updated[len(bom):]
    return updated

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--project', default='.')
    p.add_argument('--apply', action='store_true', help='Actually modify files; default is preview')
    p.add_argument('--dry-run', action='store_true')
    p.add_argument('--restore-material', action='store_true', help='Replace exact material_ui imports in lib only')
    p.add_argument('--ignore-deprecated', action='store_true', help='Add file-level suppression only to migrated files')
    p.add_argument('--format', action='store_true', help='Format non-generated Dart source files')
    p.add_argument('--test', action='store_true')
    a = p.parse_args()
    if a.apply and a.dry_run: p.error('Choose apply or dry-run')
    if a.ignore_deprecated and not a.restore_material: p.error('--ignore-deprecated requires --restore-material')
    root = Path(a.project).resolve()
    if not (root/'pubspec.yaml').is_file() or not (root/'lib').is_dir(): p.error('Select a Flutter project root')
    flutter = shutil.which('flutter')
    dart = shutil.which('dart')
    if not dart and flutter:
        candidate = Path(flutter).resolve().with_name('dart')
        if candidate.is_file(): dart = str(candidate)
    if not flutter or (a.format and not dart): p.error('Required SDK executable not found')
    files = []
    for folder in ('lib','test','integration_test','bin','tool'):
        start = root/folder
        if not start.is_dir() or start.is_symlink(): continue
        for base, dirs, names in os.walk(start, followlinks=False):
            dirs[:] = [d for d in dirs if not d.startswith('.') and d not in ('build','node_modules') and not (Path(base)/d).is_symlink()]
            for name in names:
                f = Path(base)/name
                if name.endswith('.dart') and not name.endswith(GENERATED) and not f.is_symlink(): files.append(f)
    changes = {}
    for f in sorted(files):
        old = f.read_bytes()
        new = patch(old, a.restore_material and f.is_relative_to(root/'lib'), a.ignore_deprecated)
        if old != new:
            changes[f] = new
            print(''.join(difflib.unified_diff(old.decode('utf-8').splitlines(True), new.decode('utf-8').splitlines(True), fromfile=str(f.relative_to(root)), tofile=str(f.relative_to(root)))), end='')
    print(f'\nPlanned import patches: {len(changes)}')
    def run(*cmd):
        print('>>>', ' '.join(map(str,cmd)), flush=True)
        return subprocess.run(cmd,cwd=root,check=False).returncode
    if not a.apply:
        print('Preview only. No source changes or formatting. Use --apply to authorize changes.')
        return 0 if a.dry_run else run(flutter,'analyze','--no-pub')
    backup = None
    if changes or a.format:
        backup = Path(tempfile.mkdtemp(prefix='flutter-safe-backup-'))
        for f in (files if a.format else changes):
            dest = backup/f.relative_to(root)
            dest.parent.mkdir(parents=True,exist_ok=True)
            shutil.copy2(f,dest)
        print('Backup:',backup,flush=True)
    try:
        for f,new in changes.items(): f.write_bytes(new)
        result = 0
        if a.format:
            for i in range(0,len(files),50):
                result = run(dart,'format',*[str(f.relative_to(root)) for f in files[i:i+50]]) or result
                if result: break
        if a.test: result = run(flutter,'test','--no-pub') or result
        return run(flutter,'analyze','--no-pub') or result
    finally:
        if backup: print('Original sources:',backup)
        print('Review git diff. No automatic rollback or semantic fixes performed.')

if __name__ == '__main__':
    try: sys.exit(main())
    except (OSError, KeyboardInterrupt) as exc:
        print(f'Failed or interrupted: {exc}',file=sys.stderr)
        sys.exit(1)
