#!/bin/bash

#NUMBER OF CPU CORES USED FOR COMPILATION
CORES=5

#DISTRO IDENTIFICATION
DISTO="$(lsb_release -si)"

#FOLDER HIERARCHY
BASE="$(pwd)"
CODE=$BASE/code
DEVELOPMENT=$BASE/build
KEEPERS=$BASE/keepers
DEPENDENCIES=$BASE/dependencies

#CREATE FOLDER HIERARCHY
mkdir $DEVELOPMENT $KEEPERS $DEPENDENCIES

#PULL SOFTWARE VIA GIT
git clone https://github.com/TES3MP/TES3MP.git $CODE
git clone https://github.com/OculusVR/RakNet.git $DEPENDENCIES/raknet
git clone https://github.com/zdevito/terra.git $DEPENDENCIES/terra
git clone https://github.com/TES3MP/PluginExamples.git $KEEPERS/PluginExamples

#COPY STATIC SERVER AND CLIENT CONFIGS
cp $CODE/files/tes3mp/tes3mp-{client,server}-default.cfg $KEEPERS

#INSTALL DEPENDENCIES
if [ $DISTRO = "Arch" ]; then
  sudo pacman -S git cmake boost openal openscenegraph mygui bullet qt5-base ffmpeg sdl2 unshield libxkbcommon-x11 gcc-libs clang35 llvm35
elif [[ $DISTRO = "Ubuntu" || $DISTRO = "Debian" || $DISTRO = "LinuxMint" ]]; then
  sudo apt-get install git libopenal-dev libopenscenegraph-dev libsdl2-dev libqt4-dev libboost-filesystem-dev libboost-thread-dev libboost-program-options-dev libboost-system-dev libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libswresample-dev libbullet-dev libmygui-dev libunshield-dev cmake build-essential libqt4-opengl-dev g++ llvm-3.5 clang-3.5
elif [ $DISTRO = "Fedora"]; then
  sudo dnf groupinstall development-tools openal-devel OpenSceneGraph-qt-devel SDL2-devel qt4-devel boost-filesystem git boost-thread boost-program-options boost-system ffmpeg-devel ffmpeg-libs bullet-devel gcc-c++ mygui-devel unshield-devel tinyxml-devel cmake llvm35 clang
else
  echo "Could not identify your distro, press any key to continue without installing the build dependencies."
  read
fi

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

echo -e "\n\n\n\n\nPreparing to build/upgrade..."
bash upgrade.sh --install

read

