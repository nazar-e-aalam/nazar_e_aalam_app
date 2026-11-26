#!/usr/bin/env python3
"""Explicit Flutter maintenance. No dart fix or pub get."""
import argparse
import difflib
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

IMPORT = re.compile(r'''(?m)^([ \t]*import[ \t]+)(['"])package:material_ui/material_ui\.dart\2([ \t]*;[ \t]*)$''')
MATERIAL = re.compile(r'''^[ \t]*import[ \t]+['"]package:flutter/material\.dart['"][ \t]*;''')
SHARE = re.compile(r'\bShare\s*\.\s*share\s*\(')
CODE = 'deprecated_member_use'
GENERATED = ('.g.dart', '.freezed.dart', '.mocks.dart', '.gr.dart')

def restore(s):
    return IMPORT.sub(lambda m: m[1]+m[2]+'package:flutter/material.dart'+m[2]+m[3], s)

def suppress(s, locations):
    lines = s.splitlines(keepends=True)
    if re.search(r'(?m)^[ \t]*//[ \t]*ignore_for_file:[^\n]*\bdeprecated_member_use\b', s):
        return s
    for n in sorted(set(locations), reverse=True):
        if not 1 <= n <= len(lines): continue
        line = lines[n-1]
        if not (MATERIAL.match(line) or SHARE.search(line)): continue
        prev = lines[n-2] if n > 1 else ''
        match = re.fullmatch(r'([ \t]*//[ \t]*ignore:[ \t]*)([^\n]*)(\n)?', prev)
        if match:
            if CODE not in [x.strip() for x in match[2].split(',')]:
                lines[n-2] = match[1]+match[2].rstrip()+', '+CODE+'\n'
        else:
            lines.insert(n-1, re.match(r'[ \t]*',line)[0]+'// ignore: '+CODE+'\n')
    return ''.join(lines)

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--project', default='.')
    mode = p.add_mutually_exclusive_group()
    mode.add_argument('--apply', action='store_true')
    mode.add_argument('--dry-run', action='store_true')
    p.add_argument('--restore-material', action=argparse.BooleanOptionalAction, default=True)
    p.add_argument('--ignore-deprecated', action=argparse.BooleanOptionalAction, default=True)
    p.add_argument('--format', action=argparse.BooleanOptionalAction, default=True)
    p.add_argument('--test', action='store_true')
    a = p.parse_args()
    root = Path(a.project).resolve()
    if not (root/'pubspec.yaml').is_file() or not (root/'lib').is_dir(): p.error('Select a Flutter project root')
    flutter = shutil.which('flutter')
    dart = shutil.which('dart')
    if not dart and flutter:
        candidate = Path(flutter).resolve().with_name('dart')
        if candidate.is_file(): dart = str(candidate)
    if not flutter or (a.apply and a.format and not dart): p.error('SDK executable missing')
    files = {}
    for folder in ('lib','test','integration_test','bin','tool'):
        for f in (root/folder).rglob('*.dart'):
            if f.is_symlink() or f.name.endswith(GENERATED) or any(x.startswith('.') or x in ('build','node_modules') for x in f.relative_to(root).parts): continue
            if f.resolve() != f: continue
            files[f] = f.read_bytes()
    def run(*cmd):
        print('>>>', ' '.join(cmd), flush=True)
        return subprocess.run(cmd,cwd=root).returncode
    def diagnostics():
        # Dart machine output has stable pipe-separated diagnostic fields.
        cmd = [dart,'analyze','--format=machine'] if dart else [flutter,'analyze','--no-pub','--machine']
        print('>>>',' '.join(cmd),flush=True)
        r = subprocess.run(cmd,cwd=root,capture_output=True,text=True)
        found = {}; parsed = 0
        for line in (r.stdout+'\n'+r.stderr).splitlines():
            fields = line.split('|',7)
            if len(fields)!=8 or fields[0] not in ('INFO','WARNING','ERROR'): continue
            parsed += 1
            if fields[2].lower()!=CODE: continue
            f = (root/fields[3]).resolve()
            if f in files and fields[4].isdigit(): found.setdefault(f,[]).append(int(fields[4]))
        if r.returncode and not parsed:
            raise RuntimeError('Analyzer failed: '+r.stdout+r.stderr)
        return found
    backup = None
    def snapshot():
        nonlocal backup
        if backup is None:
            backup = Path(tempfile.mkdtemp(prefix='flutter-safe-'))
            for f,data in files.items():
                dest=backup/f.relative_to(root); dest.parent.mkdir(parents=True,exist_ok=True); dest.write_bytes(data)
            print('Backup:',backup,flush=True)
    def patch(f, transform):
        raw=f.read_bytes(); old=raw.decode('utf-8-sig').replace('\r\n','\n'); new=transform(old)
        if old==new: return 0
        print(''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True),fromfile=str(f.relative_to(root)),tofile=str(f.relative_to(root)))),end='')
        if a.apply:
            snapshot()
            if f.read_bytes()!=raw: raise RuntimeError('Concurrent edit: '+str(f))
            if b'\r\n' in raw: new=new.replace('\n','\r\n')
            f.write_bytes((b'\xef\xbb\xbf' if raw.startswith(b'\xef\xbb\xbf') else b'')+new.encode('utf-8'))
        return 1
    try:
        count=0
        if a.restore_material:
            for f in sorted(files):
                if f.is_relative_to(root/'lib'): count+=patch(f,restore)
        print('Import patches:',count)
        if a.ignore_deprecated:
            found=diagnostics()
            count=sum(patch(f,lambda s: suppress(s,locations)) for f,locations in found.items())
            print('Diagnostic patches:',count)
        if not a.apply: print('Preview only; restored imports are analyzed after apply.')
        if a.dry_run: return 0
        status=0
        if a.apply and a.format:
            snapshot()
            paths=sorted(str(f.relative_to(root)) for f in files)
            for i in range(0,len(paths),50):
                status=run(dart,'format',*paths[i:i+50]) or status
                if status: break
        if a.test: status=run(flutter,'test','--no-pub') or status
        return run(flutter,'analyze','--no-pub') or status
    finally:
        if backup: print('Original sources:',backup)
        print('Review git diff. Unsupported diagnostics are left unchanged.')

if __name__=='__main__':
    try: sys.exit(main())
    except (OSError,RuntimeError,KeyboardInterrupt) as e:
        print('Stopped:',e,file=sys.stderr); sys.exit(1)
