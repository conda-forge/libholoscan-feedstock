#!/bin/bash

set -e
set -x

################################################################################
# Remove files for which there are conda packages on conda-forge channel
################################################################################
rm -vr include/CLI
# rm -vr include/concurrentqueue   # No conda package, keep and re-vend w/ licensing attached
rm -vr include/dlpack
rm -vr include/fmt
rm -vr include/nvtx3
rm -vr include/spdlog
# rm -vr include/tl-expected   # No conda package, keep and re-vend w/ licensing attached
rm -vr include/ucxx
rm -vr include/3rdparty/Eigen
rm -vr include/3rdparty/magic_enum
# rm -vr include/3rdparty/matx   # No conda package, keep and re-vend w/ licensing attached
rm -vr include/3rdparty/ucx
rm -vr include/3rdparty/yaml-cpp
# Remove CMake configuration subdirectories
rm -rv lib/cmake/CLI11
# rm -rv lib/cmake/concurrentqueue   # No conda package, keep and re-vend w/ licensing attached
rm -rv lib/cmake/dlpack
rm -rv lib/cmake/fmt
rm -rv lib/cmake/magic_enum
rm -rv lib/cmake/nvtx3
rm -rv lib/cmake/spdlog
# rm -rv lib/cmake/tl-expected   # No conda package, keep and re-vend w/ licensing attached
rm -rv lib/cmake/ucx
rm -rv lib/cmake/yaml-cpp
# Remove shared and static libraries
rm -rv lib/libfmt*
rm -rv lib/libspdlog*
rm -v lib/libuc[mpst]*
rm -v lib/libyaml-cpp*
rm -vr lib/pkgconfig
rm -vr lib/ucx

################################################################################
# Remove files for which there are conda packages on rapidsai channel
################################################################################
rm -vr include/rapids_logger
rm -vr include/rmm
# Remove CMake configuration subdirectories that have rapidsai packages
rm -rv lib/cmake/rapids_logger
rm -rv lib/cmake/rmm
rm -rv lib/cmake/ucxx
# Remove shared and static libraries
rm -v lib/libucxx*
rm -v lib/librapids_logger*
rm -v lib/librmm*

################################################################################
# Copy remaining files to conda package directory
################################################################################
cp -rv bin $PREFIX/
cp -rv examples $PREFIX/
cp -rv lib $PREFIX/
cp -rv include $PREFIX/

################################################################################
# Informational output showing what are available for packaging in meta.yaml
################################################################################
ls -l $PREFIX/
ls -l $PREFIX/bin/
ls -l $PREFIX/include/
ls -l $PREFIX/lib/
ls -l $PREFIX/lib/cmake/
ls -l $PREFIX/lib/gxf_extensions/

check-glibc $PREFIX/bin/* $PREFIX/lib/* $PREFIX/lib/gxf_extensions/*
find python/ -name "*.so*" | xargs -I"{}" check-glibc "{}"
