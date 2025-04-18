FROM ghcr.io/trilinos/trilinos:8767b9e3815ba609554acebf7e177b04fd79c61b

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
