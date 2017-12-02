#!/bin/bash -ex

rm -rf llnode

"$(dirname $0)"/common/getNode.sh # Download node tarball.

export PATH="$(cd $WORKSPACE/node-*/bin; pwd):$PATH"

export NPM_CONFIG_USERCONFIG=$WORKSPACE/npmrc
export NPM_CONFIG_CACHE=$WORKSPACE/npm-cache
node -v
npm -v
export npm_loglevel=error
npm set progress=false
ls

git clone --depth=1 -b $GIT_BRANCH https://github.com/$GIT_REPO.git llnode
cd llnode

[ $(uname) = Darwin ] && git clone --depth=1 -b release_39 https://github.com/llvm-mirror/lldb.git lldb
# Initialize GYP
git clone https://chromium.googlesource.com/external/gyp.git tools/gyp

# Configure
[ $(uname) = Linux ] && GYP_ARGS="-Dlldb_dir=/usr/lib/llvm-3.8/" || GYP_ARGS=""
./gyp_llnode $GYP_ARGS

# Build
make -C out/ -j${JOBS:-1}

npm install
npm test
