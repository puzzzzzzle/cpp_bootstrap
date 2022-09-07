# change to mirrors.aliyun.com
RUN sed -i "s/archive.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list \
    && sed -i "s/security.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list

# RUN sed -i "s@http://.*archive.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list \
#  && sed -i "s@http://.*security.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
# install libs

RUN DEBIAN_FRONTEND="noninteractive" apt-get update && apt-get -y install tzdata

RUN  apt-get install -y  \
      ssh \
      tzdata \
      \
      gcc-12 \
      g++-12 \
      build-essential \
      nasm \
      python3 \
      python3-pip \
      libgtest-dev \
      libboost-all-dev \
      \
      gdb \
      clang \
      make \
      ninja-build \
      cmake \
      autoconf \
      automake \
      locales-all \
      dos2unix \
      rsync \
      tar \
      git \
      curl \
      zip \
      unzip \
  && apt-get clean \
  && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 100 --slave /usr/bin/g++ g++ /usr/bin/g++-12 \
  && pip3 install conan

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
# not support c20
# RUN cd /tmp \
#         && git clone https://github.com/yyzybb537/libgo.git \
#         && cd libgo \
#         && mkdir build \
#         && cd build \
#         && cmake .. -DCMAKE_INSTALL_PREFIX=/usr \
#         && make -j `cat /proc/cpuinfo |grep "cores"|uniq|awk '{print $4}' \
#         && make install \
#         && cd /tmp && rm -rf libgo

# build vcpkg
# RUN cd /tmp \
#         && git clone https://github.com/Microsoft/vcpkg.git \
#         && cd vcpkg \
#         && ./bootstrap-vcpkg.sh -disableMetrics \
#         && cp vcpkg /usr/bin \
#         && cd /tmp && rm -rf vcpkg
