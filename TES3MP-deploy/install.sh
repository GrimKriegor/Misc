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
echo -e "\n\n\n>> Creating folder hierarchy"
mkdir $DEVELOPMENT $KEEPERS $DEPENDENCIES

#CHECK DISTRO AND INSTALL DEPENDENCIES
echo -e "\n\n\n>> Checking which GNU/Linux distro is installed"
case $DISTRO in
  "arch" | "parabola" )
      echo -e "\nYou seem to be running either Arch Linux or Parabola GNU/Linux-libre"
      sudo pacman -Sy
      sudo pacman -S git cmake boost openal openscenegraph mygui bullet qt5-base ffmpeg sdl2 unshield libxkbcommon-x11 gcc-libs ;; #clang35 llvm35

  "debian" | "ubuntu" | "linuxmint" )
      echo -e "\nYou seem to be running either Debian, Ubuntu or Mint"
      sudo apt-get update
      sudo apt-get install git libopenal-dev libopenscenegraph-dev libsdl2-dev libqt4-dev libboost-filesystem-dev libboost-thread-dev libboost-program-options-dev libboost-system-dev libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libswresample-dev libbullet-dev libmygui-dev libunshield-dev cmake build-essential libqt4-opengl-dev g++ ;; #llvm-3.5 clang-3.5 libclang-3.5-dev llvm-3.5-dev

  "fedora" )
      echo -e "\nYou seem to be running Fedora"
      sudo dnf --refresh groupinstall development-tools 
      sudo dnf --refresh install openal-devel OpenSceneGraph-qt-devel SDL2-devel qt4-devel boost-filesystem git boost-thread boost-program-options boost-system ffmpeg-devel ffmpeg-libs bullet-devel gcc-c++ mygui-devel unshield-devel tinyxml-devel cmake ;; #llvm35 llvm clang ncurses

  *)
      echo -e "\n\n\nCould not determine your GNU/Linux distro, press any key to continue without installing dependencies"
      read ;;
esac
    
#PULL SOFTWARE VIA GIT
echo -e "\n\n\n>> Downloading software"
git clone https://github.com/TES3MP/TES3MP.git $CODE
git clone https://github.com/OculusVR/RakNet.git $DEPENDENCIES/raknet
#git clone https://github.com/zdevito/terra.git $DEPENDENCIES/terra
wget https://github.com/zdevito/terra/releases/download/release-2016-02-26/terra-Linux-x86_64-2fa8d0a.zip -O $DEPENDENCIES/terra.zip
git clone https://github.com/TES3MP/PluginExamples.git $KEEPERS/PluginExamples

#COPY STATIC SERVER AND CLIENT CONFIGS
echo -e "\n\n\n>> Copying server and client configs to their permanent place"
cp $CODE/files/tes3mp/tes3mp-{client,server}-default.cfg $KEEPERS

#SET home VARIABLE IN tes3mp-server-default.cfg
echo -e "\n\n\n>> Autoconfiguring"
sed -i "s|~/ClionProjects/PS-dev|$KEEPERS/PluginExamples|g" $KEEPERS/tes3mp-server-default.cfg

#DIRTY HACKS
echo -e "\n\n\n>> Applying some dirty hacks"
sed -i "s|tes3mp.lua,chat_parser.lua|server.lua|g" $KEEPERS/tes3mp-server-default.cfg #Fixes server scripts
sed -i "s|Y #key for switch chat mode enabled/hidden/disabled|Left Alt|g" $KEEPERS/tes3mp-client-default.cfg #Changes chat key to Left Alt
sed -i "s|mp.tes3mp.com|grimkriegor.zalkeen.pw|g" $KEEPERS/tes3mp-client-default.cfg #Sets Grim's server as the default


#BUILD RAKNET
echo -e "\n\n\n>> Building RakNet"
mkdir $DEPENDENCIES/raknet/build
cd $DEPENDENCIES/raknet/build
cmake -DCMAKE_BUILD_TYPE=Release -DRAKNET_ENABLE_DLL=OFF -DRAKNET_ENABLE_SAMPLES=OFF -DRAKNET_ENABLE_STATIC=ON -DRAKNET_GENERATE_INCLUDE_ONLY_DIR=ON ..
make -j$CORES

cd $BASE

##BUILD TERRA
#echo -e "\n\n\n>> Building Terra"
#cd $DEPENDENCIES/terra/
#make -j$CORES

#UNPACK AND PREPARE TERRA
echo -e "\n\n\n>> Unpacking and preparing Terra"
cd $DEPENDENCIES
unzip terra.zip
mv terra-* terra
rm terra.zip

cd $BASE

echo -e "\n\n\nPreparing to build TES3MP"
bash upgrade.sh --install

read

