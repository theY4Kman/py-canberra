#!/usr/bin/env bash
set -o errexit
set -o xtrace
set -o pipefail

shopt -s extglob


ARCH="$(uname -m)"
PLAT="manylinux2014_${ARCH}"


WHEELHOUSE="/src/build/${ARCH}"
DIST_ROOT="/src/dist"
VENVS_ROOT="/src/build/venv/${ARCH}"

mkdir -p "${WHEELHOUSE}"
mkdir -p "${DIST_ROOT}"
mkdir -p "${VENVS_ROOT}"


function repair_wheel {
    wheel="$1"
    if ! auditwheel show "$wheel"; then
        echo "Skipping non-platform wheel $wheel"
    else
        auditwheel repair "$wheel" --plat "$PLAT" -w "${DIST_ROOT}"
    fi
}


cd /opt/python/
PYTAGS=$(echo cp!(35*))
cd -


# Compile wheels
for PYTAG in $PYTAGS; do
    PYBASE="/opt/python/${PYTAG}"

    VENV="${VENVS_ROOT}/${PYTAG}"
    "${PYBASE}/bin/python" -m venv "${VENV}"
    PYBIN="${VENV}/bin"

    "${PYBIN}/pip" install Cython wheel
    "${PYBIN}/pip" wheel . --no-deps -w "${WHEELHOUSE}"
done


# Bundle external shared libraries into the wheels
for whl in "${WHEELHOUSE}"/*.whl; do
    repair_wheel "$whl"
done
