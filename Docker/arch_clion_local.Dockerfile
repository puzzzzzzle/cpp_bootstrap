# Build and run:
# environment variable neededs：
#       export DOCKER_BUILDKIT=1
#       export COMPOSE_DOCKER_CLI_BUILD=1
#   docker build -t arch_clion_local:0.1 -f arch_clion_local.Dockerfile .
#   docker run -it --name cb clion_local:0.1 /bin/bash
#   docker start -ia cb
FROM archlinux:latest

# 使用镜像
RUN mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist_old \
    && echo 'Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist \
    && cat /etc/pacman.d/mirrorlist_old >> /etc/pacman.d/mirrorlist

# 更新包数据库并安装基本工具
RUN pacman -Syyu --noconfirm \
    && pacman -S --noconfirm \
    \
    tzdata \
    \
    base-devel \
    gcc \
    clang \
    cmake \
    ninja \
    nasm \
    autoconf \
    automake \
    gdb \
    \
    boost \
    gtest \
    opencv \
    fcgi \
    \
    dos2unix \
    rsync \
    tar \
    git \
    curl \
    zip \
    unzip \
    vim \
    lrzsz \
    \
    python \
    python-pip \
    pybind11 \
    python-opencv \
    \
    lua \
    luarocks \
    \
    rocksdb \
    leveldb \
    \
    rapidjson \
    protobuf \
    capnproto \
    flatbuffers \
    && pacman -Scc --noconfirm

# 安装 Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain beta

# 安装 libunifex
RUN cd /tmp \
    && git clone https://github.com/facebookexperimental/libunifex.git \
    && cd libunifex \
    && cmake -G Ninja -H. -Bbuild -DCMAKE_CXX_STANDARD:STRING=20 -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_TESTING=OFF -DUNIFEX_BUILD_EXAMPLES=OFF \
    && cd build \
    && ninja \
    && ninja install \
    && cd /tmp && rm -rf libunifex

# 安装 kcp
RUN cd /tmp \
    && git clone https://github.com/skywind3000/kcp.git \
    && cd kcp \
    && mkdir build \
    && cd build \
    && cmake .. -DCMAKE_INSTALL_PREFIX=/usr \
    && make -j `cat /proc/cpuinfo |grep "cores"|uniq|awk '{print $4}'` \
    && make install \
    && cd /tmp && rm -rf kcp

CMD ["/bin/bash"]