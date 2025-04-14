#!/bin/bash

##################################################
# This script simplifies running containers.
#
# Features:
# - Maps certificates from the host system into the container.
# - Maps ccache cache directory into the container.
# - Maps ssh-agent from host system into the container.
# - Maps git configurations into the container.
# - Preserves shell history.
# - Allows displaying graphical windows.
#
# The script looks for a
WORKSPACE=/workspace

##################################################
# load config
#
# Needs to set
# CONTAINER_NAME
# IMAGE
# PODMAN_ARGS
# PODMAN_BUILD_ARGS
# LAUNCH_COMMANDS
# CONTAINER_HOME
#
# Optional
# DOCKERFILE

command -v podman > /dev/null 2>&1
if (($? == 0 )); then
    EXECUTABLE=podman
else
    command -v docker > /dev/null 2>&1
    if (($? == 0 )); then
        EXECUTABLE=podman
    else
        echo "Neither podman nor docker are available."
        exit
    fi
fi

if [ ! -f ${PWD}/containerConfig.sh ] ; then
    echo "No containerConfig.sh in ${PWD}"
    exit
fi
source ${PWD}/containerConfig.sh

if [ -z ${CONTAINER_NAME} ] ; then
    echo "containerConfig.sh did not set CONTAINER_NAME"
    exit
fi
if [ -z ${IMAGE} ] ; then
    echo "containerConfig.sh did not set IMAGE"
    exit
fi
if [ -z ${DOCKERFILE} ] ; then
    echo "containerConfig.sh did not set DOCKERFILE"
fi
if [ -z ${CONTAINER_HOME} ] ; then
    echo "containerConfig.sh did not set CONTAINER_HOME"
    exit
fi

##################################################
# podman run arguments
# commands that are run inside the container
LAUNCH_COMMANDS+=("mkdir -p \${WORKSPACE} && cd \${WORKSPACE}")

##################################################
# Map certificates from host into container
if [ -f /etc/ssl/certs/ca-bundle.crt ] ; then
    PODMAN_ARGS+=(
        "-v/etc/ssl/certs/ca-bundle.crt:/certs/ca-bundle.crt:ro"
        "-e SSL_CERT_FILE=/certs/ca-bundle.crt"
        "-e PIP_CERT=/certs/ca-bundle.crt"
        "-e CURL_CA_BUNDLE=/certs/ca-bundle.crt"
        "-e REQUESTS_CA_BUNDLE=/certs/ca-bundle.crt"
    )
    PODMAN_BUILD_ARGS+=(
        "-v/etc/ssl/certs/ca-bundle.crt:/certs/ca-bundle.crt:ro"
        "--env" "SSL_CERT_FILE=/certs/ca-bundle.crt"
        "--env" "PIP_CERT=/certs/ca-bundle.crt"
        "--env" "CURL_CA_BUNDLE=/certs/ca-bundle.crt"
        "--env" "REQUESTS_CA_BUNDLE=/certs/ca-bundle.crt"
        "--unsetenv" "SSL_CERT_FILE"
        "--unsetenv" "PIP_CERT"
        "--unsetenv" "CURL_CA_BUNDLE"
        "--unsetenv" "REQUESTS_CA_BUNDLE"
    )
elif [ -f /etc/ssl/certs/ca-certificates.crt ] ; then
    PODMAN_ARGS+=(
        "-v/etc/ssl/certs/ca-certificates.crt:/certs/ca-certificates.crt:ro"
        "-e SSL_CERT_FILE=/certs/ca-certificates.crt"
        "-e PIP_CERT=/certs/ca-certificates.crt"
        "-e CURL_CA_BUNDLE=/certs/ca-certificates.crt"
        "-e REQUESTS_CA_BUNDLE=/certs/ca-certificates.crt"
    )
    PODMAN_BUILD_ARGS+=(
        "-v/etc/ssl/certs/ca-certificates.crt:/certs/ca-certificates.crt:ro"
        "--env" "SSL_CERT_FILE=/certs/ca-certificates.crt"
        "--env" "PIP_CERT=/certs/ca-certificates.crt"
        "--env" "CURL_CA_BUNDLE=/certs/ca-certificates.crt"
        "--env" "REQUESTS_CA_BUNDLE=/certs/ca-certificates.crt"
        "--unsetenv" "SSL_CERT_FILE"
        "--unsetenv" "PIP_CERT"
        "--unsetenv" "CURL_CA_BUNDLE"
        "--unsetenv" "REQUESTS_CA_BUNDLE"
    )
fi
if [ ! -z "${SSL_CERT_FILE}" ] ; then
    if [ -f ${SSL_CERT_FILE} ] ; then
        PODMAN_ARGS+=(
            "-v${SSL_CERT_FILE}:/certs/ssl-cert.crt:ro"
            "-e SSL_CERT_FILE=/certs/ssl-cert.crt"
        )
    else
        echo "Warning: SSL_CERT_FILE is set, but the target does not exist."
    fi
fi
if [ ! -z "${PIP_CERT}" ] ; then
    if [ -f ${PIP_CERT} ] ; then
        PODMAN_ARGS+=(
            "-v${PIP_CERT}:/certs/pip-cert.crt:ro"
            "-e PIP_CERT=/certs/pip-cert.crt"
        )
    else
        echo "Warning: PIP_CERT is set, but the target does not exist."
    fi
fi
if [ ! -z "${CURL_CA_BUNDLE}" ] ; then
    if [ -f ${CURL_CA_BUNDLE} ] ; then
        PODMAN_ARGS+=(
            "-v${CURL_CA_BUNDLE}:/certs/curl-ca-bundle:ro"
            "-e CURL_CA_BUNDLE=/certs/curl-ca-bundle.crt"
        )
    else
        echo "Warning: CURL_CA_BUNDLE is set, but the target does not exist."
    fi
fi
if [ ! -z "${REQUESTS_CA_BUNDLE}" ] ; then
    if [ -f ${REQUESTS_CA_BUNDLE} ] ; then
        PODMAN_ARGS+=(
            "-v${REQUESTS_CA_BUNDLE}:/certs/requests-ca-bundle.crt:ro"
            "-e REQUESTS_CA_BUNDLE=/certs/requests-ca-bundle.crt"
        )
    else
        echo "Warning: REQUESTS_CA_BUNDLE is set, but the target does not exist."
    fi
fi

##################################################
# ccache
mkdir -p ${HOME}/.ccache
PODMAN_ARGS+=(
    "-v${HOME}/.ccache:${WORKSPACE}/.ccache"
    "-e CCACHE_DIR=${WORKSPACE}/.ccache"
    "-e CCACHE_BASE_DIR=${WORKSPACE}/.ccache"
)

##################################################
# ssh-agent forwarding
if [ ! -z "${SSH_AUTH_SOCK}" ] ; then
    SSH_SOCKET=`readlink -f $SSH_AUTH_SOCK`
    mkdir -p ${HOME}/.container
    ln -sf $SSH_SOCKET ${HOME}/.container/ssh_socket
    PODMAN_ARGS+=(
        "-v${HOME}/.container/ssh_socket:/ssh_auth_sock"
        "-e SSH_AUTH_SOCK=/ssh_auth_sock"
    )
fi

##################################################
# expose known hosts
if [ -f ${HOME}/.ssh/known_hosts ] ; then
    PODMAN_ARGS+=("-v${HOME}/.ssh/known_hosts:${CONTAINER_HOME}/.ssh/known_hosts:ro")
fi

##################################################
# mount gitconfig
if [ -f ${HOME}/.gitconfig ] ; then
    PODMAN_ARGS+=("-v${HOME}/.gitconfig:${CONTAINER_HOME}/.gitconfig:ro")
fi

##################################################
# expose GPUs
# if command -v nvidia-smi > /dev/null 2>&1 ; then
#     PODMAN_ARGS+=("--device nvidia.com/gpu=all")
# fi

##################################################
# preserve history
mkdir -p ${HOME}/.container
touch ${HOME}/.container/${CONTAINER_NAME}.hist
PODMAN_ARGS+=("-v${HOME}/.container/${CONTAINER_NAME}.hist:${CONTAINER_HOME}/.bash_history")

##################################################
# graphical windows
if [ ! -z "${DISPLAY}" ] ; then
    PODMAN_ARGS+=("-e DISPLAY")
fi
if [ -d /tmp/.X11-unix ] ; then
    PODMAN_ARGS+=("-v/tmp/.X11-unix:/tmp/.X11-unix")
fi

##################################################
# standard launch args
PODMAN_ARGS+=(
    "--interactive"
    "--tty"

    "--pull=newer"
    "--tls-verify=false"

    "--tz=local"

    "--network=host"

    "--hostname=${CONTAINER_NAME}"
    "--name=${CONTAINER_NAME}"

    "-e WORKSPACE=${WORKSPACE}"
)

PODMAN_BUILD_ARGS+=(
    "--tls-verify=false"
    "--pull=newer"
    "--network=host"
)

LAUNCH_COMMANDS+=("bash")

##################################################
# parse command line args

POSITIONAL_ARGS=()

${EXECUTABLE} image exists ${IMAGE}
if [ $? -ne 0 ]; then
    IMAGE_EXISTS=false
else
    IMAGE_EXISTS=true
fi

${EXECUTABLE} container exists ${CONTAINER_NAME}
if [ $? -ne 0 ]; then
    CONTAINER_EXISTS=false
else
    CONTAINER_EXISTS=true
fi

USE_EXISTING_CONTAINER=true
while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--rebuild)
            USE_EXISTING_CONTAINER=false
            shift # past argument
            ;;
        -*|--*)
            echo "Unknown option $1"
            exit 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1") # save positional arg
            shift # past argument
            ;;
    esac
done
set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters


echo "Container:                 " ${CONTAINER_NAME}
echo "Image:                     " ${IMAGE}

##################################################
# build image

if ! ${IMAGE_EXISTS} ; then
    # build image
    echo "Running ${EXECUTABLE} build -t $IMAGE -f $DOCKERFILE ${PODMAN_BUILD_ARGS[@]}"
    ${EXECUTABLE} build -t ${IMAGE} -f ${DOCKERFILE} "${PODMAN_BUILD_ARGS[@]}"
fi

##################################################
# launch container

if ! ${CONTAINER_EXISTS} ; then
    # create container in detached mode
    ${EXECUTABLE} run --detach "${PODMAN_ARGS[@]}" ${IMAGE}
elif ! ${USE_EXISTING_CONTAINER} ; then
    # remove container
    ${EXECUTABLE} rm --force --time=0 ${CONTAINER_NAME}

    # create container in detached mode
    ${EXECUTABLE} run --detach "${PODMAN_ARGS[@]}" ${IMAGE}
fi

##################################################
# check if container is running
CONTAINER_IS_RUNNING=`${EXECUTABLE} container inspect -f '{{.State.Running}}' ${CONTAINER_NAME}`

if [[ "${CONTAINER_IS_RUNNING}" == "false" ]] ; then
    echo "Starting container"
    ${EXECUTABLE} start ${CONTAINER_NAME}
fi

# concatenate commands separated by semicolon
OLDIFS="$IFS"
IFS=';'
${EXECUTABLE} exec -it ${CONTAINER_NAME} bash --login -c "${LAUNCH_COMMANDS[*]}"
IFS="$OLDIFS"
