## Overview

This is a Kali container with tools I use daily when pentesting - built monthly. This is the slim cloud-tooling fork: it drops into a `/bin/bash` shell and ships cloud-pentest/cloud-audit tooling (AWS, Azure, Kubernetes, OCI, multi-cloud). gcloud / GCP tooling is intentionally not included.

### Install:

```bash
sudo podman pull ghcr.io/sir-mudkip/kali-cloud:latest
```
If using docker then replace podman with docker. Both work as they are OCI compliant.

### Alias:

I suggest that you run the following command to run the container:
```bash
kali-cloud() {
    sudo podman run \
    --rm \
    --name kali-cloud \
    --security-opt label=disable \
    --network host \
    --privileged \
    -v $HOME:/run/host \
    ghcr.io/sir-mudkip/kali-cloud:latest
}
```

- If using docker, replace the podman command with docker
- `--security-opt` is the required if SELinux is enabled
- `--privileged` is for low level network access
- `--netowork host` for catching shells
- You can update the mount to your desired directory.

### Credit:

[Finpilot](https://github.com/projectbluefin/finpilot/tree/main) for the for ideas of how to structure the container as multi-build. More changes will likely be on the way to optimise the Containerfile, but this will suffice for now.

["Shaunography"](https://gitlab.com/shaunography) for tinkering about with podman and other container designs. Please find the links below:

- https://snotra.uk/
- https://gitlab.com/snotra.uk
- https://gitlab.com/snotra.cloud
