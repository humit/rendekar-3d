# Development VM model

`rendekar-3d` uses `infra-config` as a submodule under `infra/infra-config`.

The project intentionally does not contain a devbox wrapper. Use the standard `infra-config/devbox/devbox.sh` entrypoint directly.

## Start

```bash
cd ~/src/rendekar-3d/infra/infra-config

devbox/devbox.sh up \
  --name rendekar-3d-devbox \
  --project-slug rendekar-3d \
  --workspace ~/src/rendekar-3d
```

## Auth

Use infra-config's GitHub token context mechanism. Do not copy `~/.ssh` by default.

## Patch policy

If a new VM behavior is needed, patch infra-config, not rendekar-3d.
