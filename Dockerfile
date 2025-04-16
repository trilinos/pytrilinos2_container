ARG base_image=ghcr.io/trilinos/pytrilino2_trilinos:latest

FROM ${base_image}

# Set up user for binder
ARG NB_USER=jovyan
ARG NB_UID=1006
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER} \
    && chown -R ${NB_UID} ${HOME}

USER ${NB_USER}
WORKDIR ${HOME}
ENTRYPOINT []
