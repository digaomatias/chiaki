#!/bin/bash

set -xveo pipefail

SCRIPTDIR=$(dirname "$0")
BASEDIR=$(realpath "${SCRIPTDIR}/../../")


arg1=$1
CHIAKI_SWITCH_ENABLE_LINUX="ON"
build="./build"
if [ "$arg1" != "linux" ]; then
  CHIAKI_SWITCH_ENABLE_LINUX="OFF"
  # source /opt/devkitpro/switchvars.sh
  # toolchain="${DEVKITPRO}/switch.cmake"
  toolchain="${BASEDIR}/cmake/switch.cmake"
  # export PORTLIBS_PREFIX="$(${DEVKITPRO}/portlibs_prefix.sh switch)"
  build="./build_switch"
fi

build_chiaki (){
  pushd "${BASEDIR}"
    # from debian container
    # cmake does not seems to create the
    # ${build} directory
    [ -d "${build}" ] || mkdir "${build}"

    pushd "${BASEDIR}/${build}"
    cmake \
      -DCMAKE_TOOLCHAIN_FILE="${toolchain}" \
      -DCHIAKI_ENABLE_TESTS=OFF \
      -DCHIAKI_ENABLE_CLI=OFF \
      -DCHIAKI_ENABLE_GUI=OFF \
      -DCHIAKI_ENABLE_ANDROID=OFF \
      -DCHIAKI_ENABLE_SWITCH=ON \
      -DCHIAKI_SWITCH_ENABLE_LINUX="${CHIAKI_SWITCH_ENABLE_LINUX}" \
      -DCHIAKI_LIB_ENABLE_MBEDTLS=ON \
      -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
      "${BASEDIR}"

      # -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
      # -DCMAKE_FIND_DEBUG_MODE=ON

      make -j8
    popd
  popd
}

build_chiaki

