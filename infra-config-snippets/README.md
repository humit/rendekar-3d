# infra-config integration for rendekar-3d

This directory documents the intended promotion path into the user's wider `infra-config` project.

Current project-local implementation:

```text
devbox/devbox.sh
  host-side Multipass lifecycle helper

devbox/provision-guest.sh
  guest-side Ubuntu package/environment installer
```

Desired infra-config mapping later:

```text
infra-config role/module:
  rendekar_3d_devbox

Responsibilities:
  - create/start Multipass VM
  - mount host repo into /home/ubuntu/src/rendekar-3d
  - install OpenSCAD, Python, fonts and make tooling
  - run serial-marking smoke test
```

Suggested VM defaults:

```yaml
name: rendekar-3d-devbox
image: "24.04"
cpus: 2
memory: 4G
disk: 30G
host_project_dir: "~/src/rendekar-3d"
guest_project_dir: "/home/ubuntu/src/rendekar-3d"
```

This project-local version is deliberately self-contained so the build pipeline can be prepared before the printer arrives.
