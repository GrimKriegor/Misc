#!/bin/bash

#UPDATE_SCRIPT=https://grimkriegor.zalkeen.pw/public/upgrade.sh
CORES=5

BASE="$(pwd)"
CODE=$BASE/code
DEVELOPMENT=$BASE/build
KEEPERS=$BASE/keepers
DEPENDENCIES=$BASE/dependencies

mkdir $DEVELOPMENT $KEEPERS $DEPENDENCIES

#PULL SOFTWARE VIA GIT
git clone https://github.com/TES3MP/TES3MP.git $CODE
git clone https://github.com/OculusVR/RakNet.git $DEPENDENCIES/raknet
git clone https://github.com/zdevito/terra.git $DEPENDENCIES/terra
git clone https://github.com/TES3MP/PluginExamples.git $KEEPERS/PluginExamples

#COPY STATIC SERVER AND CLIENT CONFIGS
cp $CODE/files/tes3mp/tes3mp-{client,server}-default.cfg $KEEPERS

#BUILD RAKNET
mkdir $DEPENDENCIES/raknet/build
cd $DEPENDENCIES/raknet/build
cmake -DCMAKE_BUILD_TYPE=Release -DRAKNET_ENABLE_DLL=OFF -DRAKNET_ENABLE_SAMPLES=OFF -DRAKNET_ENABLE_STATIC=ON -DRAKNET_GENERATE_INCLUDE_ONLY_DIR=ON ..
make -j$CORES

cd $BASE

#BUILD TERRA
cd $DEPENDENCIES/terra/
make -j$CORES

cd $BASE

#if [ ! -e ./upgrade.sh ]; then
#  wget $UPDATE_SCRIPT
#fi

echo -e "\n\n\n\n\nPreparing to build/upgrade..."
bash upgrade.sh --install

read

