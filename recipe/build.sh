#!/bin/bash

# create dpcpp environment
echo "ls -la \$(dirname \$0)"
ls -la $(dirname "$0")
tee > /tmp/oneAPI.repo << EOF
[oneAPI]
name=Intel(R) oneAPI repository
baseurl=https://yum.repos.intel.com/oneapi
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
EOF
mv /tmp/oneAPI.repo $(dirname "$0")/

echo "ls -la \$(dirname \$0)"
ls -la $(dirname "$0")
echo $(dirname "$0")/oneAPI.repo
ls -la $(dirname "$0")/oneAPI.repo

echo "/home/conda/feedstock_root/build_artifacts/daal4py_*/work/oneAPI.repo"
ls -la /home/conda/feedstock_root/build_artifacts/daal4py_*/work/oneAPI.repo

echo "oneAPI.repo"
ls -la oneAPI.repo

export DPCPPROOT=$(dirname "$0")/oneAPI.repo/compiler/latest

# args definition
if [ "$PY3K" == "1" ]; then
    ARGS="--single-version-externally-managed --record=record.txt"
else
    ARGS="--old-and-unmanageable"
fi

# if dpc++ vars path is specified
if [ ! -z "${DPCPPROOT}" ]; then
    source ${DPCPPROOT}/env/vars.sh
    export CC=dpcpp
    export CXX=dpcpp
    dpcpp --version
fi

# if DAALROOT not exists then provide PREFIX
if [ "${DAALROOT}" != "" ] && [ "${DALROOT}" == "" ] ; then
    export DALROOT="${DAALROOT}"
fi

if [ -z "${DALROOT}" ]; then
    export DALROOT=${PREFIX}
fi

if [ "$(uname)" == "Darwin" ]; then
    # dead_strip_dylibs does not work with DAAL, which is underlinked by design
    export LDFLAGS="${LDFLAGS//-Wl,-dead_strip_dylibs}"
    export LDFLAGS_LD="${LDFLAGS_LD//-dead_strip_dylibs}"
    # some dead_strip_dylibs come from Python's sysconfig. Setting LDSHARED overrides that
    export LDSHARED="-bundle -undefined dynamic_lookup -flto -Wl,-export_dynamic -Wl,-pie -Wl,-headerpad_max_install_names"
fi

export DAAL4PY_VERSION=$PKG_VERSION
export MPIROOT=${PREFIX}
${PYTHON} setup.py install $ARGS
