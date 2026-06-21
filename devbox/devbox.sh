#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INFRA_CONFIG="${ROOT}/infra/infra-config"

if [ ! -x "${INFRA_CONFIG}/projects/rendekar-3d/devbox.sh" ]; then
  echo "Missing infra-config devbox script."
  echo "Try:"
  echo "  git submodule update --init --recursive"
  exit 1
fi

exec "${INFRA_CONFIG}/projects/rendekar-3d/devbox.sh" "$@"
