#!/usr/bin/env bash
set -o errexit
set -o xtrace
set -o pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$SCRIPT_DIR"


# First, clean everything up
rm -r build/ dist/ *.egg-info canberra/*.c || true


# Build all the wheels
cd "$SCRIPT_DIR/packaging"
docker-compose run --rm manylinux2014_x86_64
docker-compose run --rm manylinux2014_i686
cd "$SCRIPT_DIR"


# Build our source distribution
python setup.py sdist
