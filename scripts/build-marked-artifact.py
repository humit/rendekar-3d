#!/usr/bin/env python3
from __future__ import annotations

import argparse
from datetime import datetime
from pathlib import Path
import subprocess
import yaml


def load_yaml(path: Path):
    return yaml.safe_load(path.read_text())


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--job', required=True, type=Path)
    ap.add_argument('--artifact-id', required=True)
    ap.add_argument('--physical-mark', required=True)
    ap.add_argument('--render', action='store_true', help='Call OpenSCAD to generate STL, not only SCAD')
    args = ap.parse_args()

    job = load_yaml(args.job)
    ts = datetime.now().strftime('%Y%m%d-%H%M%S')
    project = job['project']
    version = job['model_version']
    slicer_name = job['slicer']['name'].lower().replace(' ', '-')
    build_id = f'{ts}-{slicer_name}-{args.physical_mark.lower()}'
    build_dir = Path('builds') / project / version / build_id
    marked_dir = build_dir / 'marked'
    marked_dir.mkdir(parents=True, exist_ok=True)

    input_stl = Path(job['model']['path'])
    output_stl = marked_dir / f'{input_stl.stem}_{args.physical_mark}_marked.stl'
    scad_output = output_stl.with_suffix('.scad')

    marking = job.get('marking', {})
    cmd = [
        'python3', 'scripts/mark-stl-bottom.py',
        '--input', str(input_stl),
        '--mark', args.physical_mark,
        '--output', str(output_stl),
        '--scad-output', str(scad_output),
        '--size', str(marking.get('default_text_size_mm', 3.2)),
        '--depth', str(marking.get('default_depth_mm', 0.4)),
        '--font', str(marking.get('default_font', 'Liberation Sans:style=Bold')),
        '--rotate-deg', str(marking.get('default_rotate_deg', 90)),
    ]
    if not args.render:
        cmd.append('--no-render')
    subprocess.run(cmd, check=True)

    manifest = {
        'build_id': build_id,
        'artifact_id': args.artifact_id,
        'physical_mark': args.physical_mark,
        'job_file': str(args.job),
        'project': project,
        'model_version': version,
        'input_model': str(input_stl),
        'marked_stl': str(output_stl),
        'generated_scad': str(scad_output),
        'status': 'MARKED_STL_READY' if args.render else 'SCAD_READY',
        'printer': job.get('printer'),
        'filament': job.get('filament'),
        'slicer': job.get('slicer'),
        'marking': marking,
    }
    manifest_path = build_dir / 'manifest.yaml'
    manifest_path.write_text(yaml.safe_dump(manifest, sort_keys=False, allow_unicode=True))
    print(f'build_id={build_id}')
    print(f'build_dir={build_dir}')
    print(f'manifest={manifest_path}')
    print(f'scad={scad_output}')
    if args.render:
        print(f'marked_stl={output_stl}')
    else:
        print('Marked STL not rendered yet. Install OpenSCAD and rerun with --render.')

if __name__ == '__main__':
    main()
