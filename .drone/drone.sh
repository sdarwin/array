#!/bin/bash

# Copyright 2020 Rene Rivera, Sam Darwin
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE.txt or copy at http://boost.org/LICENSE_1_0.txt)

set -e
export TRAVIS_BUILD_DIR=$(pwd)
export DRONE_BUILD_DIR=$(pwd)
export TRAVIS_BRANCH=$DRONE_BRANCH
export VCS_COMMIT_ID=$DRONE_COMMIT
export GIT_COMMIT=$DRONE_COMMIT
export REPO_NAME=$DRONE_REPO
export PATH=~/.local/bin:/usr/local/bin:$PATH

if [ "$DRONE_JOB_BUILDTYPE" == "boost" ]; then

echo '==================================> INSTALL'

BOOST_BRANCH=develop && [ "$TRAVIS_BRANCH" == "master" ] && BOOST_BRANCH=master || true
cd ..
git clone -b $BOOST_BRANCH --depth 1 https://github.com/boostorg/boost.git boost-root
cd boost-root
git submodule update --init tools/build
git submodule update --init libs/config
git submodule update --init tools/boostdep
cp -r $TRAVIS_BUILD_DIR/* libs/array
python tools/boostdep/depinst/depinst.py array
./bootstrap.sh
./b2 headers

echo '==================================> SCRIPT'

echo "using $TOOLSET : : $COMPILER ;" > ~/user-config.jam
./b2 -j 3 libs/array/test toolset=$TOOLSET cxxstd=$CXXSTD

elif [ "$DRONE_JOB_BUILDTYPE" == "96ad197d74-2319b6d45f" ]; then

echo '==================================> INSTALL'

BOOST_BRANCH=develop && [ "$TRAVIS_BRANCH" == "master" ] && BOOST_BRANCH=master || true
git clone -b $BOOST_BRANCH --depth 1 https://github.com/boostorg/assert.git ../assert
git clone -b $BOOST_BRANCH --depth 1 https://github.com/boostorg/config.git ../config
git clone -b $BOOST_BRANCH --depth 1 https://github.com/boostorg/core.git ../core
git clone -b $BOOST_BRANCH --depth 1 https://github.com/boostorg/static_assert.git ../static_assert
git clone -b $BOOST_BRANCH --depth 1 https://github.com/boostorg/throw_exception.git ../throw_exception

echo '==================================> SCRIPT'

mkdir __build__ && cd __build__
cmake ../test/test_cmake
cmake --build .

fi
