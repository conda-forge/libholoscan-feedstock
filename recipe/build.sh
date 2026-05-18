#!/bin/bash

set -e
set -x

################################################################################
# Remove files for which there are conda packages on conda-forge channel
################################################################################
rm -vr include/CLI
# rm -vr include/concurrentqueue   # No conda package, keep and re-vend w/ licensing attached
rm -vr include/cccl                 # cccl: provided by conda-forge `cccl`
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
rm -rv lib/cmake/cccl                # cccl: provided by conda-forge `cccl`
rm -rv lib/cmake/cub                 # cccl: provided by conda-forge `cccl`
rm -rv lib/cmake/cudax               # cccl: provided by conda-forge `cccl`
rm -rv lib/cmake/dlpack
rm -rv lib/cmake/fmt
rm -rv lib/cmake/libcudacxx          # cccl: provided by conda-forge `cccl`
rm -rv lib/cmake/magic_enum
# rm -rv lib/cmake/matx          # No conda package, keep and re-vend w/ licensing attached
rm -rv lib/cmake/nvtx3
rm -rv lib/cmake/spdlog
rm -rv lib/cmake/thrust              # cccl: provided by conda-forge `cccl`
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
rm -fv bin/ucx_info bin/ucx_perftest

################################################################################
# Relocate and curate non-binary files from the upstream tarball
################################################################################
# Move the scripts README out of bin/ to share/doc/holoscan/, then prepend a
# note acknowledging that not every script documented upstream is included in
# this conda package.
mkdir -p $PREFIX/share/doc/holoscan
{
    cat <<'NOTE'
> **NOTE**: This is the upstream Holoscan scripts README. Not every script
> documented below is included in this conda package — only a curated subset
> ships under `$CONDA_PREFIX/bin` and `$CONDA_PREFIX/share/holoscan/test`.

NOTE
    cat bin/README.md
} > $PREFIX/share/doc/holoscan/README.md
rm -fv bin/README.md

# Move test_pattern_validation.py out of bin/: it's a package-install validator,
# not a user-facing executable on PATH.
mkdir -p $PREFIX/share/holoscan/test
mv -v bin/test_pattern_validation.py $PREFIX/share/holoscan/test/test_pattern_validation.py

# Drop CI-only helper that is not documented as a user-facing tool in the
# upstream scripts README.
rm -fv bin/ctest_time_comparison.py

# libgcc_s.so as a GCC linker-script redirector must come from the compiler
# runtime package, not this redist.
rm -fv lib/libgcc_s.so

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

# Only run check-glibc against actual ELF binaries. The unfiltered glob would
# include Python scripts, shell scripts, README.md, and GCC linker scripts —
# each producing a readelf "Not an ELF file" error that masks real issues.
find $PREFIX/bin $PREFIX/lib $PREFIX/lib/gxf_extensions -maxdepth 1 -type f \
    -exec sh -c 'if file -b "$1" | grep -q "^ELF"; then check-glibc "$1"; fi' _ {} \;
find python/ -name "*.so*" -exec check-glibc {} \;
