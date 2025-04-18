# Trilinos in a container

This repository contains Dockerfiles for two images:

- [`dependencies`](https://github.com/users/trilinos/packages/container/package/dependencies): an image with dependencies for Trilinos/PyTrilinos2
- [`trilinos`](https://github.com/users/trilinos/packages/container/package/trilinos): an image with pre-installed Trilinos

You can run the second image [online](#runOnBinder).
Both images can also be [pulled](#pull) from the GitHub Container Registry.


## [Running in the cloud](#runOnBinder)

PyTrilinos2 can be run directly for free from the browser on a JupyterHub server hosted at https://mybinder.org/

Just click here to launch a notebook server:
[![Binder](http://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/trilinos/pytrilinos2_container/binder)


## [Running locally](#runningLocally)

You can either pull the images from the GitHub Container Registry or build them yourself.

In either case, please install `podman` or `docker` first.


### [Pulling the images](#pull)

To pull the image with PyTrilinos2 pre-installed, run
```
podman pull ghcr.io/trilinos/trilinos:latest
```

To pull an image with only the dependencies for PyTrilinos2, run
```
podman pull ghcr.io/trilinos/dependencies:latest
```

### [Running locally](#local)

To locally run a container using the image with pre-installed Trilinos, run
```
./containerLauncher.sh -c trilinos
```
The JupyterHub server will be available at https://127.0.0.1:9999

In order to build Trilinos locally, run
```
./containerLauncher.sh -c dependencies
```
This will
1) Build the image with Trilinos dependencies (unless it has been previously built or pulled).
2) Clone Trilinos (unless there is a folder trilinos/source already.
3) Launch a container with source and build directory mapped from host.

Once in the container Trilinos can be configured and built using
```
configure_trilinos
build_trilinos
```
The configuration for the build can be found in [trilinos-build.cmake](https://github.com/trilinos/pytrilinos2_container/blob/main/trilinos-build.cmake).
