#!/bin/bash

SCRIPT_PATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

CONFIG=trilinos

while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--config)
            shift
            CONFIG="$1"
            shift # past argument
            ;;
        *)
            POSITIONAL_ARGS+=("$1") # save positional arg
            shift # past argument
            ;;
    esac
done
set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

if [[ $CONFIG == "dependencies" ]] ; then
    ##################################################
    # container name
    CONTAINER_NAME=pytrilinos2-dependencies

    ##################################################
    # image
    CONTAINER_HOME=/root

    IMAGE=ghcr.io/trilinos/dependencies:latest
    DOCKERFILE=${SCRIPT_PATH}/Dockerfile.dependencies

    TRILINOS_SRC=${TRILINOS_SRC:=${SCRIPT_PATH}/trilinos/source}
    [ ! -d "${TRILINOS_SRC}" ] && git clone --branch develop git@github.com:trilinos/Trilinos.git ${TRILINOS_SRC}

    KOKKOS_TOOLS_SRC=${KOKKOS_TOOLS_SRC:=${SCRIPT_PATH}/kokkos-tools/source}
    [ ! -d "${KOKKOS_TOOLS_SRC}" ] && git clone --branch develop git@github.com:kokkos/kokkos-tools.git ${KOKKOS_TOOLS_SRC}

    PODMAN_ARGS+=(
        "-v${TRILINOS_SRC}:${WORKSPACE}/trilinos/source"
        "-v${TRILINOS_BUILD}:${WORKSPACE}/trilinos/build"
        "-v${TRILINOS_INSTALL}:${WORKSPACE}/trilinos/install"
        "-e TRILINOS_SRC_HOST=${TRILINOS_SRC}"
        "-e TRILINOS_BUILD_HOST=${TRILINOS_BUILD}"
        "-e TRILINOS_INSTALL_HOST=${TRILINOS_INSTALL}"

        "-v${KOKKOS_TOOLS_SRC}:${WORKSPACE}/kokkos-tools/source"
        "-v${KOKKOS_TOOLS_BUILD}:${WORKSPACE}/kokkos-tools/build"
        "-v${KOKKOS_TOOLS_INSTALL}:${WORKSPACE}/kokkos-tools/install"
        "-e KOKKOS_TOOLS_SRC_HOST=${KOKKOS_TOOLS_SRC}"
        "-e KOKKOS_TOOLS_BUILD_HOST=${KOKKOS_TOOLS_BUILD}"
        "-e KOKKOS_TOOLS_INSTALL_HOST=${KOKKOS_TOOLS_INSTALL}"
    )

elif [[ $CONFIG == "trilinos" ]] ; then
    ##################################################
    # container name
    CONTAINER_NAME=pytrilinos2-trilinos

    ##################################################
    # image
    CONTAINER_HOME=/root

    IMAGE=ghcr.io/trilinos/trilinos:latest
    DOCKERFILE=${SCRIPT_PATH}/Dockerfile.trilinos

fi

PODMAN_ARGS+=(
    "-e OMP_NUM_THREADS=2"
    "-v${SCRIPT_PATH}:/scripts:ro"
)
PODMAN_BUILD_ARGS=()
LAUNCH_COMMANDS+=("source /scripts/commandsDevContainer.sh")

##################################################
# Trilinos

TRILINOS_BUILD=${TRILINOS_BUILD:=${SCRIPT_PATH}/trilinos/build}
TRILINOS_INSTALL=${TRILINOS_INSTALL:=${SCRIPT_PATH}/trilinos/install}

mkdir -p ${TRILINOS_BUILD}
mkdir -p ${TRILINOS_INSTALL}

PODMAN_ARGS+=(
    "-e TRILINOS_DIR=${WORKSPACE}/trilinos/source"
    "-e TRILINOS_BUILD_DIR=${WORKSPACE}/trilinos/build"
    "-e TRILINOS_INSTALL_DIR=${WORKSPACE}/trilinos/install"
    "-e PYTHONPATH=${WORKSPACE}/trilinos/build/packages/PyTrilinos2"
)

LAUNCH_COMMANDS+=("cd \${TRILINOS_BUILD_DIR}")


##################################################
# Kokkos Tools

KOKKOS_TOOLS_BUILD=${KOKKOS_TOOLS_BUILD:=${SCRIPT_PATH}/kokkos-tools/build}
KOKKOS_TOOLS_INSTALL=${KOKKOS_TOOLS_INSTALL:=${SCRIPT_PATH}/kokkos-tools/install}

mkdir -p ${KOKKOS_TOOLS_BUILD}
mkdir -p ${KOKKOS_TOOLS_INSTALL}

PODMAN_ARGS+=(
    "-e KOKKOS_TOOLS_DIR=${WORKSPACE}/kokkos-tools/source"
    "-e KOKKOS_TOOLS_BUILD_DIR=${WORKSPACE}/kokkos-tools/build"
    "-e KOKKOS_TOOLS_INSTALL_DIR=${WORKSPACE}/kokkos-tools/install"
)


##################################################
# Jupyter notebook server

mkdir -p ${SCRIPT_PATH}/notebooks
NOTEBOOK_PORT=9999
PODMAN_ARGS+=(
    "-e NOTEBOOK_PORT=${NOTEBOOK_PORT}"
    "-p${NOTEBOOK_PORT}:${NOTEBOOK_PORT}"
    "-v${SCRIPT_PATH}/notebooks:${WORKSPACE}/notebooks"
)
LAUNCH_COMMANDS+=(
    "jupyter notebook --port=${NOTEBOOK_PORT} --no-browser --allow-root --ip=0.0.0.0 --NotebookApp.token='' --NotebookApp.password='' --notebook-dir=${WORKSPACE}/notebooks > /dev/null 2>&1 & echo 'Jupyter Notebook server started.'"
)
