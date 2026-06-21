#!/usr/bin/env bash
set -euo pipefail

# rendekar-3d Multipass devbox helper for macOS hosts.
# Creates/starts an Ubuntu VM, mounts this repo into ~/src/rendekar-3d,
# and runs the guest bootstrap/provisioning script.

NAME="rendekar-3d-devbox"
CPUS="2"
MEMORY="4G"
DISK="30G"
IMAGE="24.04"
MOUNT="1"
PROVISION="1"
PROJECT_DIR=""
GUEST_SRC_ROOT="/home/ubuntu/src"
GUEST_PROJECT_DIR="${GUEST_SRC_ROOT}/rendekar-3d"

usage() {
  cat <<USAGE
Usage: devbox/devbox.sh <command> [options]

Commands:
  up          Create/start VM, mount repo, run provisioner
  start       Start existing VM
  stop        Stop VM
  shell       Open shell in VM project directory
  provision   Run guest provisioning only
  status      Show Multipass VM status
  delete      Delete and purge VM

Options:
  --name NAME          VM name [${NAME}]
  --cpus N             CPU count [${CPUS}]
  --memory SIZE        Memory [${MEMORY}]
  --disk SIZE          Disk size [${DISK}]
  --image IMAGE        Ubuntu image [${IMAGE}]
  --project-dir PATH   Host repo path [auto-detect]
  --no-mount           Do not mount host project into VM
  --no-provision       Do not run guest provisioning during up

Examples:
  devbox/devbox.sh up
  devbox/devbox.sh shell
  devbox/devbox.sh provision
  devbox/devbox.sh delete
USAGE
}

log() { printf '[rendekar-3d devbox] %s\n' "$*"; }
fail() { printf '[rendekar-3d devbox] ERROR: %s\n' "$*" >&2; exit 1; }

need_multipass() {
  command -v multipass >/dev/null 2>&1 || fail "multipass not found. Install Multipass on macOS first."
}

repo_root() {
  if [[ -n "${PROJECT_DIR}" ]]; then
    cd "${PROJECT_DIR}" && pwd
    return
  fi
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  cd "${script_dir}/.." && pwd
}

vm_exists() {
  multipass info "${NAME}" >/dev/null 2>&1
}

ensure_vm() {
  need_multipass
  if vm_exists; then
    log "Using existing VM: ${NAME}"
  else
    log "Creating VM ${NAME}: image=${IMAGE} cpus=${CPUS} memory=${MEMORY} disk=${DISK}"
    multipass launch "${IMAGE}" --name "${NAME}" --cpus "${CPUS}" --memory "${MEMORY}" --disk "${DISK}"
  fi
  log "Starting VM: ${NAME}"
  multipass start "${NAME}" >/dev/null 2>&1 || true
}

ensure_mount() {
  [[ "${MOUNT}" == "1" ]] || return 0
  local root
  root="$(repo_root)"
  log "Ensuring guest source root exists: ${GUEST_SRC_ROOT}"
  multipass exec "${NAME}" -- mkdir -p "${GUEST_SRC_ROOT}"

  if multipass info "${NAME}" | grep -Fq "${GUEST_PROJECT_DIR}"; then
    log "Mount already present: ${root} -> ${GUEST_PROJECT_DIR}"
  else
    log "Mounting ${root} -> ${GUEST_PROJECT_DIR}"
    multipass mount "${root}" "${NAME}:${GUEST_PROJECT_DIR}"
  fi
}

run_provision() {
  [[ "${PROVISION}" == "1" ]] || return 0
  log "Running guest provisioner"
  multipass exec "${NAME}" -- bash -lc "cd '${GUEST_PROJECT_DIR}' && bash devbox/provision-guest.sh"
}

cmd="${1:-}"
[[ -n "${cmd}" ]] || { usage; exit 1; }
shift || true

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) NAME="$2"; shift 2 ;;
    --cpus) CPUS="$2"; shift 2 ;;
    --memory) MEMORY="$2"; shift 2 ;;
    --disk) DISK="$2"; shift 2 ;;
    --image) IMAGE="$2"; shift 2 ;;
    --project-dir) PROJECT_DIR="$2"; shift 2 ;;
    --no-mount) MOUNT="0"; shift ;;
    --no-provision) PROVISION="0"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) fail "Unknown option: $1" ;;
  esac
done

case "${cmd}" in
  up)
    ensure_vm
    ensure_mount
    run_provision
    log "Ready. Enter with: devbox/devbox.sh shell --name ${NAME}"
    ;;
  start)
    need_multipass
    multipass start "${NAME}"
    ;;
  stop)
    need_multipass
    multipass stop "${NAME}"
    ;;
  shell)
    need_multipass
    multipass exec "${NAME}" -- bash -lc "cd '${GUEST_PROJECT_DIR}' && exec bash"
    ;;
  provision)
    need_multipass
    run_provision
    ;;
  status)
    need_multipass
    multipass info "${NAME}"
    ;;
  delete)
    need_multipass
    log "Deleting VM: ${NAME}"
    multipass delete "${NAME}" --purge
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    usage
    fail "Unknown command: ${cmd}"
    ;;
esac
