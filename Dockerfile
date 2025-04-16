FROM ghcr.io/cgcgcg/trilinos:e1a31e21d4948fa419f3132d1fa97f7310c671ff

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
