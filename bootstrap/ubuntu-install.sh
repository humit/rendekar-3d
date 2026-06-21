#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update
sudo apt-get install -y \
  git \
  make \
  python3 \
  python3-pip \
  python3-venv \
  openscad \
  fonts-liberation \
  fontconfig

python3 -m pip install --user --upgrade pyyaml

cat <<'MSG'
Bootstrap complete.

Notes:
- OpenSCAD is used for serial engraving/debossing into STL files.
- OrcaSlicer/Bambu Studio AppImage can be installed separately once you want CLI slicing.
- The current MVP can generate marked STL files before the printer arrives.
MSG
