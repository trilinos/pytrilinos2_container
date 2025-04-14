# Trilinos in a container

This repo contains Dockerfiles for three images:

- `pytrilinos2_dependencies`: an image with dependencies for Trilinos/PyTrilinos2
- `pytrilinos2_trilinos`: an image with pre-installed Trilinos
- `pytrilinos2_binder`: an image with changes for https://mybinder.org/

The first two images are appropriate for running locally, the last one for running in the cloud.


## [Running in the cloud](#runOnBinder)

PyTrilinos2 can be run directly for free from the browser on a JupyterHub server hosted at https://mybinder.org/

Just click here to launch a notebook server: MISSING_LINK


## [Running locally](#runningLocally)

You can either pull the images from the GitHub Container Registry or build them yourself.

In either case, please install `podman` or `docker` first.


### [Pulling the images](#pull)

To pull the image with PyTrilinos2 pre-installed, run
```
podman pull ghcr.io/trilinos/pynucleus2_container/pynucleus_trilinos:latest
```

To pull an image with only the dependencies, run
```
podman pull ghcr.io/trilinos/pynucleus2_container/pynucleus_dependencies:latest
```

### [Building locally](#build)

Run
```
./contanerLauncher.sh
```

This will

1) Build an image with Trilinos dependencies (unless it has been previously built or pulled).
2) Clone Trilinos (unless there is a folder trilinos/source already.
3) Launch a container with source and build directory mapped from host.

Once in the container, run
```
configure_trilinos
build_trilinos
```
to configure and build Trilinos. The configuration are a couple of CMake fragments.
