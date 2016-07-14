#!/bin/bash

#NUMBER OF CPU CORES USED FOR COMPILATION
CORES=5

#DISTRO IDENTIFICATION
DISTRO="$(lsb_release -si | awk '{print tolower($0)}')"

#FOLDER HIERARCHY
BASE="$(pwd)"
CODE=$BASE/code
DEVELOPMENT=$BASE/build
KEEPERS=$BASE/keepers
DEPENDENCIES=$BASE/dependencies

#CREATE FOLDER HIERARCHY
mkdir $DEVELOPMENT $KEEPERS $DEPENDENCIES

#CHECK DISTRO AND INSTALL DEPENDENCIES
case $DISTRO in
  "arch")
      sudo pacman -S git cmake boost openal openscenegraph mygui bullet qt5-base ffmpeg sdl2 unshield libxkbcommon-x11 gcc-libs ;; #clang35 llvm35

  "debian" | "ubuntu" | "linuxmint" )
      sudo apt-get install git libopenal-dev libopenscenegraph-dev libsdl2-dev libqt4-dev libboost-filesystem-dev libboost-thread-dev libboost-program-options-dev libboost-system-dev libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libswresample-dev libbullet-dev libmygui-dev libunshield-dev cmake build-essential libqt4-opengl-dev g++ ;; #llvm-3.5 clang-3.5 libclang-3.5-dev llvm-3.5-dev

  "fedora" )
      sudo dnf groupinstall development-tools 
      sudo dnf install openal-devel OpenSceneGraph-qt-devel SDL2-devel qt4-devel boost-filesystem git boost-thread boost-program-options boost-system ffmpeg-devel ffmpeg-libs bullet-devel gcc-c++ mygui-devel unshield-devel tinyxml-devel cmake ;; #llvm35 llvm clang ncurses

  *)
      echo "Could not determine your GNU/Linux distro, press any key to continue without installing dependencies"
      read ;;
esac
    
#PULL SOFTWARE VIA GIT
git clone https://github.com/TES3MP/TES3MP.git $CODE
git clone https://github.com/OculusVR/RakNet.git $DEPENDENCIES/raknet
#git clone https://github.com/zdevito/terra.git $DEPENDENCIES/terra
wget https://github.com/zdevito/terra/releases/download/release-2016-02-26/terra-Linux-x86_64-2fa8d0a.zip -O $DEPENDENCIES/terra.zip
git clone https://github.com/TES3MP/PluginExamples.git $KEEPERS/PluginExamples

#COPY STATIC SERVER AND CLIENT CONFIGS
cp $CODE/files/tes3mp/tes3mp-{client,server}-default.cfg $KEEPERS

#SET home VARIABLE IN tes3mp-server-default.cfg
sed -i "s|~/ClionProjects/PS-dev|$KEEPERS/PluginExamples|g" $KEEPERS/tes3mp-server-default.cfg

#DIRTY HACKS
sed -i "s|tes3mp.lua,chat_parser.lua|server.lua|g" $KEEPERS/tes3mp-server-default.cfg

#BUILD RAKNET
mkdir $DEPENDENCIES/raknet/build
cd $DEPENDENCIES/raknet/build
cmake -DCMAKE_BUILD_TYPE=Release -DRAKNET_ENABLE_DLL=OFF -DRAKNET_ENABLE_SAMPLES=OFF -DRAKNET_ENABLE_STATIC=ON -DRAKNET_GENERATE_INCLUDE_ONLY_DIR=ON ..
make -j$CORES

cd $BASE

##BUILD TERRA
#cd $DEPENDENCIES/terra/
#make -j$CORES

#PREPARE TERRA
cd $DEPENDENCIES
unzip terra.zip
mv terra-* terra
rm terra.zip

cd $BASE

echo -e "\n\n\n\n\nPreparing to build/upgrade..."
bash upgrade.sh --install

read

