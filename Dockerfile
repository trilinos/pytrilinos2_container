FROM ghcr.io/trilinos/trilinos:b4ab3eea3af19954bd7931978bf82e1d4bd51a98

USER ubuntu
RUN cp -r /scripts/notebooks /home/ubuntu
WORKDIR /home/ubuntu/notebooks
ENV SHELL /bin/bash
