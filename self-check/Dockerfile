FROM ubuntu:18.04

RUN apt-get update && apt-get install -y wget && \
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-keyring_1.0-1_all.deb -O /tmp/cuda-keyring_1.0-1_all.deb && \
    dpkg -i /tmp/cuda-keyring_1.0-1_all.deb && \
    apt-get update && \
    apt-get -y install cuda-toolkit-11-8 && \
    apt-get install -y build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
