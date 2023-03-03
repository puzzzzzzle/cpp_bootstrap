# syntax = edrevo/dockerfile-plus

# Build and run:
# environment variable neededs：
#       export DOCKER_BUILDKIT=1
#       export COMPOSE_DOCKER_CLI_BUILD=1
#   docker build -t puzzzzzzle/clion_local:0.1 -f clion_local.Dockerfile .
#   docker run -it --name cb -v /home/tao:/home/tao puzzzzzzle/clion_local:0.8.4 /bin/bash
#   docker start -ia cb
FROM ubuntu:22.04

# change to mirror
# RUN sed -i "s/archive.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list \
#     && sed -i "s/security.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list
#change to sjtu
RUN sed -i 's/archive.ubuntu.com/mirror.sjtu.edu.cn/g' /etc/apt/sources.list

# RUN sed -i "s@http://.*archive.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list \
#  && sed -i "s@http://.*security.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
# install libs

RUN DEBIAN_FRONTEND="noninteractive" apt-get update && apt-get -y install tzdata

# basic env
RUN  apt-get install -y  \
     \
     gcc-12 \
     g++-12 \
     build-essential \
     nasm \
     gdb \
     clang \
     make \
     ninja-build \
     cmake \
     autoconf \
     automake \
     python3-pip \
     python3 \
     && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 100 --slave /usr/bin/g++ g++ /usr/bin/g++-12 \
     && apt-get clean

# 3rd libs
RUN  apt-get install -y  \
     libgtest-dev \
     libboost-all-dev \
     && apt-get clean


# linux kernel build needs
# for build speed, only install qemu-system-x86_64
#RUN  apt-get update && apt-get install -y  \
#     qemu-system-x86 \
#     fakeroot \
#     ncurses-dev \
#     xz-utils \
#     libssl-dev \
#     bc \
#     flex \
#     libelf-dev \
#     bison \
#     cpio \
#     && apt-get clean


# tools
RUN  apt-get update && apt-get install -y  \
     ssh \
     locales-all \
     dos2unix \
     rsync \
     tar \
     git \
     curl \
     zip \
     unzip \
     vim \
     && apt-get clean

# python libs
RUN pip3 install \
    conan


# libs
RUN  apt-get update && apt-get install -y  \
     python3-dev \
     pybind11-dev \
     python3-dev \
     rapidjson-dev \
     libopencv-dev \
     python3-opencv \
     libfcgi-dev \
     libleveldb-dev \
     iproute2 \
     libprotobuf-dev \
     protobuf-compiler \
     capnproto \
     libcapnp-dev \
     flatbuffers-compiler \
     libflatbuffers-dev \
     && apt-get clean


####  build libs


# build libunifex
RUN cd /tmp \
    && git clone https://github.com/facebookexperimental/libunifex.git \
    && cd libunifex \
    && cmake -G Ninja -H. -Bbuild -DCMAKE_CXX_STANDARD:STRING=20 -DCMAKE_INSTALL_PREFIX=/usr \
    && cd build \
    && ninja \
    && ninja install \
    && cd /tmp && rm -rf libunifex


# build libgo
# not support c++20
# RUN cd /tmp \
#         && git clone https://github.com/yyzybb537/libgo.git \
#         && cd libgo \
#         && mkdir build \
#         && cd build \
#         && cmake .. -DCMAKE_INSTALL_PREFIX=/usr \
#         && make -j `cat /proc/cpuinfo |grep "cores"|uniq|awk '{print $4}'` \
#         && make install \
#         && cd /tmp && rm -rf libgo

# build vcpkg
# RUN cd /tmp \
#         && git clone https://github.com/Microsoft/vcpkg.git \
#         && cd vcpkg \
#         && ./bootstrap-vcpkg.sh -disableMetrics \
#         && cp vcpkg /usr/bin \
#         && cd /tmp && rm -rf vcpkg

# build kcp
RUN cd /tmp \
    && git clone https://github.com/skywind3000/kcp.git \
    && cd kcp \
    && mkdir build \
    && cd build \
    && cmake .. -DCMAKE_INSTALL_PREFIX=/usr \
    && make -j `cat /proc/cpuinfo |grep "cores"|uniq|awk '{print $4}'` \
    && make install \
    && cd /tmp && rm -rf kcp
################## libs end