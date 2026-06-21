# infra-config integration idea

Use infra-config to create a Linux VM/devbox, mount `~/src/rendekar-3d`, and run:

```bash
cd ~/src/rendekar-3d
make bootstrap
```

Later this can become an infra-config role/task:

- install `openscad`, `fonts-liberation`, `python3`, `pip`, `make`, `git`
- optionally install OrcaSlicer AppImage into `/opt/orcaslicer/`
- create `~/src/rendekar-3d`
- run a smoke test:
  `make mark-render ARTIFACT=DS-V3B-0001 MARK=D3B001`
