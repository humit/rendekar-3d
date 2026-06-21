# rendekar-3d

`rendekar-3d` is a 3D-printing build pipeline and product-lab repository.

The current focus is traceable prototyping for small wearable 3D-printed parts, starting with the Dino Scale accessory series. The repository tracks model versions, slicer/build metadata, physical artifact serials, print QA results, and photos.

## Repository responsibilities

This repository owns the **3D printing/product pipeline**:

- model sources and STL files
- print job definitions
- serial/mark generation
- marked STL build artifacts
- slicer result manifests
- physical print QA logs
- photos and prototype decisions

This repository does **not** own the devbox lifecycle implementation. VM creation, Multipass handling, workspace mounting, GitHub token context, and Ubuntu provisioning are handled by `infra-config`.

## Development environment architecture

`rendekar-3d` uses `infra-config` as a git submodule:

```text
rendekar-3d/
  infra/
    infra-config/        # git submodule, branch: rendekar-3d-devbox

  models/
  jobs/
  scripts/
  builds/
  print-logs/
  photos/
```

There is intentionally **no `rendekar-3d/devbox/devbox.sh` wrapper**.

Use the standard `infra-config` devbox command directly from the submodule. `infra-config` should resolve or be told that the project workspace is the parent `rendekar-3d` repository and that the project slug is `rendekar-3d`.

The important separation is:

```text
infra-config:
  Multipass VM lifecycle
  workspace mount
  host GitHub token context
  guest provisioning

rendekar-3d:
  model/build/serial/QA pipeline
```

## Add infra-config as a submodule

From the `rendekar-3d` repository root:

```bash
mkdir -p infra
git submodule add -b rendekar-3d-devbox <INFRA_CONFIG_GIT_URL> infra/infra-config
git commit -m "Add infra-config submodule for development VM"
```

On a fresh clone:

```bash
git submodule update --init --recursive
```

## Start the Ubuntu development VM

Run the standard `infra-config` devbox script from the submodule.

Preferred shape:

```bash
cd ~/src/rendekar-3d/infra/infra-config

devbox/devbox.sh up \
  --name rendekar-3d-devbox \
  --project-slug rendekar-3d \
  --workspace ~/src/rendekar-3d
```

If the checked-out `infra-config` branch already derives workspace/slug for submodule usage, the command may be shorter:

```bash
cd ~/src/rendekar-3d/infra/infra-config
devbox/devbox.sh up --name rendekar-3d-devbox
```

The expected VM mount points are:

```text
/home/ubuntu/src/rendekar-3d
/home/ubuntu/src/infra-config
```

## GitHub authentication model

Use the existing `infra-config` GitHub token context mechanism. Do **not** default to copying the host `~/.ssh` directory into the VM.

Expected host-side context:

```text
~/.config/infra-config/github-token
```

Expected behavior when starting the devbox:

```text
infra-config exports host GitHub token context
infra-config makes token context available in the VM
VM can use gh/git HTTPS auth for pull/push
```

SSH sync should be an explicit fallback only, not the default path.

## Build pipeline concept

The print pipeline is treated like a physical CI/CD pipeline:

```text
source model
  -> assign artifact serial
  -> engrave/deboss serial into bottom of STL
  -> create marked STL
  -> slice
  -> print
  -> record QA result
  -> keep/revise/reject decision
```

Two IDs are tracked separately:

```text
build_id     = the slicer/build event
artifact_id  = the physical printed object
physical_mark = compact text engraved into the object
```

Example:

```yaml
build_id: 20260621-085811-orcaslicer-d3b001
artifact_id: DS-V3B-0001
physical_mark: D3B001
```

## Generate a marked STL

Inside the Ubuntu VM, from the mounted repo:

```bash
cd ~/src/rendekar-3d
make bootstrap
make artifact
make mark-render ARTIFACT=DS-V3B-0001 MARK=D3B001
```

The marked STL and manifest are generated under:

```text
builds/dino-scale/v3b/<build-id>/marked/
builds/dino-scale/v3b/<build-id>/manifest.yaml
```

The marking method is bottom-side engraved/debossed text. For the small Dino Scale parts, compact marks such as `D3B001` are preferred over long serials.

## Finish a print

After a physical print, record the result:

```bash
python3 scripts/finish-print.py \
  --artifact-id DS-V3B-0001 \
  --status QA_PASS \
  --actual-time "10m05s" \
  --notes "Serial readable, first layer good, top surface acceptable"
```

Allowed QA statuses:

```text
QA_PASS
QA_REVISE
QA_FAIL
QA_REPRINT
QA_BLOCKED
```

## Clone workflow on a new Mac

```bash
cd ~/src
git clone <RENDEKAR_3D_GIT_URL> rendekar-3d
cd rendekar-3d
git submodule update --init --recursive

cd infra/infra-config
devbox/devbox.sh up \
  --name rendekar-3d-devbox \
  --project-slug rendekar-3d \
  --workspace ~/src/rendekar-3d
```

Then enter the VM using the standard infra-config command, for example:

```bash
cd ~/src/rendekar-3d/infra/infra-config
devbox/devbox.sh shell --name rendekar-3d-devbox
```

## Notes for agents

Do not reimplement devbox logic in this repository.

If the devbox workflow needs new behavior, patch `infra-config` on its `rendekar-3d-devbox` branch, then update the submodule pointer in this repository.

Do not add a local wrapper unless explicitly requested. The intended pattern is that `infra-config` remains the owner of devbox behavior and is reusable by future projects.
