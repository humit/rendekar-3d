# rendekar-3d devbox

This is a small infra-config-style Multipass wrapper for macOS hosts.
It creates an Ubuntu VM, mounts the current `rendekar-3d` repo into the VM, installs the required environment, and runs a smoke test that generates a serial-marked STL.

## Host requirement

Install Multipass on macOS first.

## Create/start/provision

```bash
cd ~/src/rendekar-3d
devbox/devbox.sh up
```

Defaults:

- VM name: `rendekar-3d-devbox`
- Ubuntu image: `24.04`
- CPUs: `2`
- Memory: `4G`
- Disk: `30G`
- Mount: host repo -> `/home/ubuntu/src/rendekar-3d`

## Enter the VM

```bash
devbox/devbox.sh shell
```

## Run provisioning again

```bash
devbox/devbox.sh provision
```

## Stop/delete

```bash
devbox/devbox.sh stop
devbox/devbox.sh delete
```

## Why this belongs here

`infra-config` can later absorb this as a reusable devbox module, but this project-local version makes `rendekar-3d` self-bootstrapping today.
