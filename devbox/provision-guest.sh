#!/usr/bin/env bash
set -euo pipefail

# Guest-side Ubuntu provisioning for rendekar-3d.
# This intentionally avoids depending on the printer being present.
# It prepares the serial engraving/build pipeline and runs a smoke test.

log() { printf '[rendekar-3d provision] %s\n' "$*"; }

cd "$(dirname "${BASH_SOURCE[0]}")/.."
PROJECT_ROOT="$(pwd)"

log "Project root: ${PROJECT_ROOT}"

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get install -y \
  ca-certificates \
  curl \
  git \
  jq \
  make \
  python3 \
  python3-pip \
  python3-venv \
  openscad \
  fonts-liberation \
  fontconfig \
  file \
  tree

python3 -m pip install --user --break-system-packages --upgrade pyyaml >/dev/null 2>&1 || \
python3 -m pip install --user --upgrade pyyaml

mkdir -p builds print-logs/artifacts photos

log "Tool versions"
python3 --version
openscad --version || true
fc-match 'Liberation Sans:style=Bold' || true

log "Running serial engraving smoke test"
python3 scripts/build-marked-artifact.py \
  --job jobs/dino-scale-v3b-a1mini-pla-mintlime-orca.yaml \
  --artifact-id DS-V3B-0001 \
  --physical-mark D3B001 \
  --render

log "Smoke test complete. Latest build directories:"
find builds/dino-scale/v3b -maxdepth 2 -type f | sort | tail -20

cat <<'MSG'

Provisioning complete.

Useful commands inside the VM:
  make artifact
  make mark-render ARTIFACT=DS-V3B-0001 MARK=D3B001
  make finish-pass ARTIFACT=DS-V3B-0001 NOTES="Serial readable; first layer good."

The printer does not need to be connected for the current MVP.
MSG
