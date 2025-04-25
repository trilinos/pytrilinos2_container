FROM ghcr.io/trilinos/trilinos:56886e6ffb7480e70676678c6a7de48937f78401

USER ubuntu
RUN cp -r /scripts/notebooks /home/ubuntu
WORKDIR /home/ubuntu/notebooks
ENV SHELL /bin/bash
