## Overview

This is a Kali container with tools I use daily when pentesting - built monthly. This is the systemd-enabled, cloud-tooling fork: it boots with `/sbin/init` so in-container services can be managed, and it ships cloud-pentest/cloud-audit tooling (AWS, Azure, Kubernetes, OCI, multi-cloud) on top of the on-network/AD toolset. gcloud / GCP tooling is intentionally not included.

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
    -d \
    --name kali-cloud \
    --security-opt label=disable \
    --network host \
    --privileged \
    -v $HOME:/run/host \
    ghcr.io/sir-mudkip/kali-cloud:latest
}
```

Once you have booted the container, you can enter it in an interactive bash shell with the following:
```bash
sudo podman exec -ti kali-cloud bash
```

- If using docker, replace the podman command with docker
- `--security-opt` is the required if SELinux is enabled
- `--privileged` is for low level network access
- `--netowork host` for catching shells
- You can update the mount to your desired directory.

> [!NOTE]
> To use tools like hashcat in this container, you will need the Nvidia drivers and the Nvidias container toolkit to enable GPU passthru. The CUDA toolkit can be installed in the container and if you enable passthru it should just work.
> I have not included the toolkit to save space and efficiency, though if you would like to include it you can go [here](https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Debian&target_version=12&target_type=deb_local) and build a dedicated .sh file for install. I personally would suggest a dedicated hashcat image which I have made intentionally for use with [distrobox](https://github.com/Sir-Mudkip/hashcat-distrobox.git).



### Systemd Services:

This image boots with `/sbin/init`, so systemd services (docker, postgresql, sshd, etc.) can be started and managed inside the container with `systemctl`. Run the container `--privileged` (see the alias above) for this to work. For example, `systemctl enable --now docker` to bring up the in-container Docker daemon (configured with the `vfs` storage driver), or `systemctl enable --now ssh` for sshd.

### Credit:

[Finpilot](https://github.com/projectbluefin/finpilot/tree/main) for the for ideas of how to structure the container as multi-build. More changes will likely be on the way to optimise the Containerfile, but this will suffice for now.

["Shaunography"](https://gitlab.com/shaunography) for tinkering about with podman and other container designs. Please find the links below:

- https://snotra.uk/
- https://gitlab.com/snotra.uk
- https://gitlab.com/snotra.cloud
