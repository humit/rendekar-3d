#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path
import re
import yaml

INDEX = Path('print-logs/artifact-index.yaml')


def load_index():
    if INDEX.exists():
        return yaml.safe_load(INDEX.read_text()) or {'artifacts': {}}
    return {'artifacts': {}}


def save_index(data):
    INDEX.parent.mkdir(parents=True, exist_ok=True)
    INDEX.write_text(yaml.safe_dump(data, sort_keys=True, allow_unicode=True))


def next_serial(data, prefix):
    nums = []
    pat = re.compile(rf'^{re.escape(prefix)}-(\d+)$')
    for k in data.get('artifacts', {}):
        m = pat.match(k)
        if m:
            nums.append(int(m.group(1)))
    return max(nums, default=0) + 1


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--project-code', default='DS')
    ap.add_argument('--model-version', required=True, help='e.g. V3B')
    ap.add_argument('--build-id', default=None)
    args = ap.parse_args()

    prefix = f'{args.project_code}-{args.model_version.upper()}'
    data = load_index()
    n = next_serial(data, prefix)
    artifact_id = f'{prefix}-{n:04d}'
    physical_mark = f'D{args.model_version.upper().replace("V", "")}{n:03d}'
    # e.g. DS-V3B-0001 -> D3B001

    data.setdefault('artifacts', {})[artifact_id] = {
        'artifact_id': artifact_id,
        'physical_mark': physical_mark,
        'status': 'DRAFT',
        'build_id': args.build_id,
        'log': f'print-logs/artifacts/{artifact_id}.yaml',
    }
    save_index(data)

    log_path = Path('print-logs/artifacts') / f'{artifact_id}.yaml'
    log_path.parent.mkdir(parents=True, exist_ok=True)
    log_path.write_text(yaml.safe_dump({
        'artifact_id': artifact_id,
        'physical_mark': physical_mark,
        'status': 'DRAFT',
        'build_id': args.build_id,
        'physical_print': None,
        'qa': None,
    }, sort_keys=False))

    print(f'artifact_id={artifact_id}')
    print(f'physical_mark={physical_mark}')
    print(f'log={log_path}')

if __name__ == '__main__':
    main()
