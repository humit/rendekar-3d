# rendekar-3d

Traceable 3D printing build pipeline for physical prototypes.

Current MVP goals:

1. Keep model versions, slicer settings and physical QA logs in git.
2. Generate a unique physical artifact ID per prototype.
3. Engrave/deboss a short serial mark into the bottom of the STL before slicing.
4. Produce a build manifest that maps model source -> marked STL -> slicer output -> physical print result.

Terminology:

- `build_id`: one generated build/slice attempt.
- `artifact_id`: one physical printed object.
- `physical_mark`: short text engraved into the print, e.g. `D3B001`.
- `QA_PASS`, `QA_REVISE`, `QA_FAIL`, `QA_REPRINT`, `QA_BLOCKED`: final physical result values.

First target model:

- `models/dino-scale/v3b/dino_scale_v3b_organic_safe_23x32x3p6mm.stl`


## Devbox

Development is expected to happen on macOS with an Ubuntu Multipass VM.
Create/start/provision the VM with:

```bash
devbox/devbox.sh up
```

Enter it with:

```bash
devbox/devbox.sh shell
```

The devbox installs OpenSCAD, Python tooling and fonts, then runs a smoke test that generates a serial-engraved STL before any printer is required.

See `docs/devbox.md` and `devbox/README.md`.
