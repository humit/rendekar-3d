#!/usr/bin/env python3
from __future__ import annotations

import argparse
from datetime import datetime, timezone
from pathlib import Path
import yaml

VALID = {'QA_PASS', 'QA_REVISE', 'QA_FAIL', 'QA_REPRINT', 'QA_BLOCKED'}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('artifact_id')
    ap.add_argument('--status', required=True, choices=sorted(VALID))
    ap.add_argument('--actual-time', default=None)
    ap.add_argument('--notes', default='')
    args = ap.parse_args()

    path = Path('print-logs/artifacts') / f'{args.artifact_id}.yaml'
    if not path.exists():
        raise SystemExit(f'No artifact log found: {path}')
    data = yaml.safe_load(path.read_text()) or {}
    data['status'] = args.status
    data['updated_at'] = datetime.now(timezone.utc).isoformat()
    data['physical_print'] = data.get('physical_print') or {}
    data['physical_print']['actual_time'] = args.actual_time
    data['physical_print']['status'] = args.status
    data['qa'] = data.get('qa') or {}
    data['qa'].setdefault('notes', [])
    if args.notes:
        data['qa']['notes'].append(args.notes)
    path.write_text(yaml.safe_dump(data, sort_keys=False, allow_unicode=True))
    print(f'updated {path}: {args.status}')

if __name__ == '__main__':
    main()
