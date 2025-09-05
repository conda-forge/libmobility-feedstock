#!/bin/bash

set -euxo pipefail
rm -rf build || true
mkdir build
cd build
# CUDA 12.8 onwards defines all architectures by default
if [ -z ${CUDAARCHS+x} ]; then
  CUDAARCHS=$(nvcc --list-gpu-code | tr ' ' '\n' \
      | grep -E '^sm_[0-9]+$' \
      | sed 's/sm_//;s/$/-real/' \
      | paste -sd';' -)
fi
CMAKE_FLAGS="${CMAKE_ARGS} -DCMAKE_PREFIX_PATH=${PREFIX} -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_BUILD_TYPE=Release"
CMAKE_FLAGS+=" -DCMAKE_VERBOSE_MAKEFILE=y"
CMAKE_FLAGS+=" -DFETCHCONTENT_SOURCE_DIR_UAMMD=${SRC_DIR}/uammd-src"
CMAKE_FLAGS+=" -DFETCHCONTENT_SOURCE_DIR_LANCZOS=${SRC_DIR}/lanczos-src"
CMAKE_FLAGS+=" -DFETCHCONTENT_QUIET=OFF"
CMAKE_FLAGS+=" -DCMAKE_CUDA_ARCHITECTURES=${CUDAARCHS}"
cmake ${SRC_DIR} ${CMAKE_FLAGS}
make install -j$CPU_COUNT
