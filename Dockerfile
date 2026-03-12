FROM ghcr.io/trilinos/trilinos:b4ab3eea3af19954bd7931978bf82e1d4bd51a98

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid 1000 \
    ubuntu
USER ubuntu
RUN cp -r /workspace/trilinos/build/packages/PyTrilinos2/examples/notebooks /home/ubuntu
WORKDIR /home/ubuntu/notebooks
ENV SHELL=/bin/bash
