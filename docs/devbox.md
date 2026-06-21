# Devbox workflow

The project is developed from macOS but runs its build tooling in Ubuntu.
The VM layer is intentionally separate from the 3D print pipeline:

```text
macOS host
  -> Multipass Ubuntu VM
  -> mounted ~/src/rendekar-3d
  -> Ubuntu packages + Python dependencies
  -> OpenSCAD serial engraving smoke test
```

## First setup

```bash
cd ~/src/rendekar-3d
devbox/devbox.sh up
```

This creates or starts the VM and runs:

```bash
bash devbox/provision-guest.sh
```

The provisioner installs:

```text
git
make
python3
python3-pip
openscad
fonts-liberation
fontconfig
jq
tree
```

Then it runs a smoke test:

```bash
python3 scripts/build-marked-artifact.py \
  --job jobs/dino-scale-v3b-a1mini-pla-mintlime-orca.yaml \
  --artifact-id DS-V3B-0001 \
  --physical-mark D3B001 \
  --render
```

Expected result:

```text
builds/dino-scale/v3b/<build-id>/marked/*D3B001_marked.stl
builds/dino-scale/v3b/<build-id>/manifest.yaml
```

## Normal development session

```bash
devbox/devbox.sh shell
make artifact
make mark-render ARTIFACT=DS-V3B-0002 MARK=D3B002
```

## Notes

- The printer is not required for this stage.
- OrcaSlicer/Bambu Studio CLI installation can be added later once the serial-marked STL generation is stable.
- Keep VM creation/provisioning here until it is mature enough to promote back into the wider `infra-config` repo.
