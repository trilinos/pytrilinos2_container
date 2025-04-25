# Trilinos in a container

This repository contains Dockerfiles for two images:

- [`dependencies`](https://github.com/users/trilinos/packages/container/package/dependencies): an image with dependencies for Trilinos/PyTrilinos2
- [`trilinos`](https://github.com/users/trilinos/packages/container/package/trilinos): an image with pre-installed Trilinos

You can run the second image online on a JupyterHub server hosted at https://mybinder.org/.
Click here to launch the server: [![Binder](http://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/trilinos/pytrilinos2_container/binder?urlpath=lab/tree/PyTrilinos2.ipynb)

Both images can also be pulled from the GitHub Container Registry or built locally.


## Running locally

To use the images locally, please install `podman` or `docker`.

To locally run a container using the image with pre-installed Trilinos, run
```
./containerLauncher.sh -c trilinos
```
The JupyterHub server will be available at 127.0.0.1:9999

In order to build Trilinos from scratch in the container, run
```
./containerLauncher.sh -c dependencies
```
This will
1) Build the image with Trilinos dependencies (unless it has been previously built or pulled).
2) Clone Trilinos (unless there already is a folder trilinos/source).
3) Launch a container with source and build directory mapped from host.

Once in the container Trilinos can be configured and built using
```
configure_trilinos
build_trilinos
```
The configuration for the build can be found in [trilinos-build.cmake](https://github.com/trilinos/pytrilinos2_container/blob/main/trilinos-build.cmake).


# License and Copyright

See LICENSE and COPYRIGHT in this repository.
