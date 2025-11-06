# Yocto Docker Development Environment

A containerized Yocto build environment with NFS rootfs serving capability.

## Key Features

- **Clean build environment**: Pre-configured Ubuntu 22.04 container with all Yocto dependencies
- **NFS rootfs serving**: Dedicated container to serve target board's root filesystem
- **Split workflow support**: Able to build on remote server, serve NFS locally
- **Persistent storage**: Docker volumes preserve builds and configurations

Default target: BeagleBone Black (suitable for Bootlin's Yocto training)

Currently the scripts are only for Linux and macOS. On windows you can use `docker compose` command manually for now.

## Requirements

- Docker and Docker compose installed
- 100GB+ free disk space (for building Yocto)
- NFS kernel modules enabled (Linux)

## Quick Start

Choose setup based on your needs:

### Local setup (most common)

Both Yocto and NFS containers run on the same machine.

```bash
git clone --recursive https://github.com/shengt25/yocto-docker.git
cd yocto-docker
./run.sh
```

### Remote setup

Build on powerful server, serve NFS locally. 

**Remote server:**

```bash
git clone --recursive https://github.com/shengt25/yocto-docker.git
cd yocto-docker/remote-setup
./run_yocto.sh
```

**Local machine:**

```bash
git clone --recursive https://github.com/shengt25/yocto-docker.git
cd yocto-docker/remote-setup
./run_nfs.sh
```

Continue to [Remote Deployment](#remote-deployment), for deployment workflow

## Usage

After running the setup script, the Yocto container will be built/started and activated in your terminal, ready to use!

**Notes**

- Yocto container's possword: `yocto`
- Container stops when you exit (not removed), data persists.
- NFS version: NFSv4 (set `nfsvers=4` in target's `extlinux.conf`)
- Firewall: Open port `2049` for NFS connections from target board

## Remote Deployment 

After both server and machine setup, the deployment can be easilty done with scripts:

#### Update rootfs to local NFS (for quick testing)

```bash
./update_rootfs.sh user@remote-ip
```

It will connect to the remote server, fetch the rootfs image and overwrite the data in local nfs server container. Done automatically and clean, no cache/temp files left.

#### Pull disk image (For flashing SD cards)

```bash
./pull_image.sh user@remote-ip
```

This will pull the image (`wic.xz` format) to the current directory. You can use it to flash SD cards.

#### Options:

**For both scripts**

- `-i <image prefix>`: Image name prefix (default: `core-image-minimal`)
- `-y`: Skip confirmation
- `-h`: Show help

## Architecture

### Components

**Containers:**

1. Yocto Development Environment based on Ubuntu 22.04 with necessary dependencies pre-installed
2. NFS Server providing root filesystem for the target device over network

(For local setup they are on the same machine. For remote setup, on two machines.)

**Docker Volumes:**

- `yocto-data` - Yocto lab data and build artifacts
- `yocto-nfs` - NFS server root filesystem data
- `yocto-user` - User data in the Yocto container

### Diagram

**Local Setup**

```
┌───────────────────────────────────────────┐      ┌──────────────┐
│              Local Machine                │      │  BeagleBone  │
│   ┌─────────────┐         ┌────────────┐  │      │              │
│   │ Yocto Build │         │ NFS Server │◄─┼──────┤  NFS Mount   │
│   │ Container   ├────────►│ Container  │  │      │              │
│   └─────────────┘         └────────────┘  │      │              │
│                                           │      │              │
│                                           │      │              │
└───────────────────────────────────────────┘      └──────────────┘
```

**Remote Setup**

```
┌─────────────────────┐                   ┌──────────────────┐      ┌──────────────┐
│  Remote Server      │                   │  Local Machine   │      │  BeagleBone  │
│  ┌───────────────┐  │                   │  ┌────────────┐  │      │              │
│  │ Yocto Build   │  │ update_rootfs.sh  │  │ NFS Server │◄─┼──────┤  NFS Mount   │
│  │ Container     ├──┼─────────────────────►│ Container  │  │      │              │
│  │               │  │                   │  └────────────┘  │      │              │
│  │               │  │ pull_image.sh     │                  │      │              │
│  │               ├──┼──────────────────►│                  │      │              │
│  └───────────────┘  │                   │                  │      │              │
│                     │                   │                  │      │              │
└─────────────────────┘                   └──────────────────┘      └──────────────┘
```

## Maintenance

**Reset container** (preserve all volumes data but lost settings)

 ```bash
 ./rebuild_yocto.sh
 ```

**Delete all data** (remove volumes):

```bash 
docker volume rm yocto-data yocto-nfs yocto-user 
```

Scripts will be added soon.

## Troubleshooting

**NFS server fails to start on Linux:**

On Linux, the container requires `nfs` and `nfsd` kernel modules. The NFS server will fail with it. You check on your computer using:

```bash
lsmod | grep nfs
```

If you couldn't find `nfs` and `nfsd`, enable them using:

```bash
sudo modprobe nfs 
sudo modprobe nfsd
```

Run the first command again to check it is enabled.

Add `nfs` and `nfsd` in  `/etc/modules-load.d/nfs.conf` to load automatically on boot.

## Acknowledgements

The NFS server container is based on [obeone/docker-nfs-server](https://github.com/obeone/docker-nfs-server), which is forked and improved upon [ehough/docker-nfs-server](https://github.com/ehough/docker-nfs-server)

The development environment setup is inspired by [antonsaa/yocto-dev](https://gitlab.metropolia.fi/antonsaa/yocto-dev)
