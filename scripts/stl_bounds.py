#!/usr/bin/env python3
"""Small STL bounds helper with no third-party dependency.
Supports common binary and ASCII STL files.
"""
from __future__ import annotations

import re
import struct
from pathlib import Path
from typing import Iterable, Tuple

Point = Tuple[float, float, float]


def _is_probably_binary(path: Path) -> bool:
    data = path.read_bytes()
    if len(data) < 84:
        return False
    tri_count = struct.unpack('<I', data[80:84])[0]
    expected = 84 + tri_count * 50
    return expected == len(data)


def iter_vertices(path: Path) -> Iterable[Point]:
    if _is_probably_binary(path):
        data = path.read_bytes()
        tri_count = struct.unpack('<I', data[80:84])[0]
        offset = 84
        for _ in range(tri_count):
            # normal 12 bytes, then 3 vertices, then attribute 2 bytes
            offset += 12
            for _v in range(3):
                yield struct.unpack('<fff', data[offset:offset + 12])
                offset += 12
            offset += 2
    else:
        text = path.read_text(errors='ignore')
        for m in re.finditer(r'vertex\s+([-+0-9.eE]+)\s+([-+0-9.eE]+)\s+([-+0-9.eE]+)', text):
            yield (float(m.group(1)), float(m.group(2)), float(m.group(3)))


def bounds(path: Path):
    verts = list(iter_vertices(path))
    if not verts:
        raise ValueError(f'No vertices found in {path}')
    xs = [p[0] for p in verts]
    ys = [p[1] for p in verts]
    zs = [p[2] for p in verts]
    return {
        'min': (min(xs), min(ys), min(zs)),
        'max': (max(xs), max(ys), max(zs)),
        'size': (max(xs) - min(xs), max(ys) - min(ys), max(zs) - min(zs)),
        'center': ((min(xs) + max(xs)) / 2, (min(ys) + max(ys)) / 2, (min(zs) + max(zs)) / 2),
    }


if __name__ == '__main__':
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument('stl')
    args = ap.parse_args()
    b = bounds(Path(args.stl))
    print(b)
