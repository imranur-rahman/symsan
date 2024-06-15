FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

WORKDIR /workdir
COPY . /workdir/symsan

RUN apt-get update
RUN apt-get install -y cmake llvm-12 clang-12 libc++-12-dev libc++abi-12-dev python3-minimal python-is-python3 zlib1g-dev git joe libprotobuf-dev python3-pip
# RUN apt install -y build-essential libboost-system-dev libboost-thread-dev libboost-program-options-dev libboost-test-dev libboost-filesystem-dev
RUN apt-get install -y libboost-all-dev
RUN git clone --depth=1 https://github.com/AFLplusplus/AFLplusplus /workdir/aflpp
ENV LLVM_CONFIG=llvm-config-12
RUN cd /workdir/aflpp && CC=clang-12 CXX=clang++-12 make install

RUN apt-get install -y libz3-dev libgoogle-perftools-dev
RUN apt clean

RUN cd symsan/ && mkdir -p build && \
    cd build && CC=clang-12 CXX=clang++-12 cmake -DCMAKE_INSTALL_PREFIX=. -DCMAKE_INSTALL_PREFIX="/usr/include/boost" -DAFLPP_PATH=/workdir/aflpp ../  && \
    make -j4 && make install
#  -DCMAKE_CXX_PREFIX='-march=apple-latest'

RUN pip install lit && cd /workdir/symsan/build && lit tests

ENV KO_CC=clang-12
ENV KO_CXX=clang++-12
ENV KO_USE_FASTGEN=1
