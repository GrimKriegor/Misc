#!/bin/bash

#NUMBER OF CPU CORES USED FOR COMPILATION
if [ "$1" == "" ]; then
    CORES="$(cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l)"
else
    CORES="$1"
fi

#DISTRO IDENTIFICATION
DISTRO="$(lsb_release -si | awk '{print tolower($0)}')"

#FOLDER HIERARCHY
BASE="$(pwd)"
CODE="$BASE/code"
DEVELOPMENT="$BASE/build"
KEEPERS="$BASE/keepers"
DEPENDENCIES="$BASE/dependencies"

#CREATE FOLDER HIERARCHY
echo -e ">> Creating folder hierarchy"
mkdir "$DEVELOPMENT" "$KEEPERS" "$DEPENDENCIES"

#CHECK DISTRO AND INSTALL DEPENDENCIES
echo -e "\n>> Checking which GNU/Linux distro is installed"
case $DISTRO in
  "arch" | "parabola" | "manjarolinux" )
      echo -e "You seem to be running either Arch Linux, Parabola GNU/Linux-libre or Manjaro"
      sudo pacman -Sy git cmake boost openal openscenegraph mygui bullet qt5-base ffmpeg sdl2 unshield libxkbcommon-x11 ncurses #clang35 llvm35

      if [ ! -d "/usr/share/licenses/gcc-libs-multilib/" ]; then
            sudo pacman -S gcc-libs
      fi

      echo -e "\nCreating symlinks for ncurses compatibility"
      LIBTINFO_VER=6
      NCURSES_VER="$(pacman -Q ncurses | awk '{sub(/-[0-9]+/, "", $2); print $2}')"
      sudo ln -s /usr/lib/libncursesw.so."$NETCURSES_VER" /usr/lib/libtinfo.so."$LIBTINFO_VER" 2> /dev/null
      sudo ln -s /usr/lib/libtinfo.so."$LIBTINFO_VER" /usr/lib/libtinfo.so 2> /dev/null
  ;;

  "debian" | "devuan" )
      echo -e "You seem to be running Debian or Devuan"
      sudo apt-get update
      sudo apt-get install git libopenal-dev qt5-default libopenscenegraph-3.4-dev libsdl2-dev libqt4-dev libboost-filesystem-dev libboost-thread-dev libboost-program-options-dev libboost-system-dev libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libswresample-dev libmygui-dev libunshield-dev cmake build-essential libqt4-opengl-dev g++ libncurses5-dev #libbullet-dev
      #echo -e "\nDebian users are required to build OpenSceneGraph from source\nhttps://wiki.openmw.org/index.php?title=Development_Environment_Setup#Build_and_install_OSG\n\nType YES if you want the script to do it automatically (THIS IS BROKEN ATM)\nIf you already have it installed or want to do it manually,\npress ENTER to continue"
      #read INPUT
      #if [ "$INPUT" == "YES" ]; then
      #      echo -e "\nOpenSceneGraph will be built from source"
      #      BUILD_OSG=true
      #      sudo apt-get build-dep openscenegraph libopenscenegraph-dev
      #fi
      sudo apt-get build-dep bullet
      BUILD_BULLET=true
  ;;

  "ubuntu" | "linuxmint" )
      echo -e "You seem to be running either Ubuntu or Mint"
      echo -e "\nUbuntu and Mint users are required to enable the OpenMW PPA repository\nhttps://wiki.openmw.org/index.php?title=Development_Environment_Setup#Ubuntu\n\nType YES if you want the script to do it automatically\nIf you already have it enabled or want to do it manually,\npress ENTER to continue"
      read INPUT
      if [ "$INPUT" == "YES" ]; then
            echo -e "\nEnabling the OpenMW PPA repository..."
            sudo add-apt-repository ppa:openmw/openmw
            echo -e "Done!"
      fi
      sudo apt-get update
      sudo apt-get install git libopenal-dev qt5-default libopenscenegraph-3.4-dev libsdl2-dev libqt4-dev libboost-filesystem-dev libboost-thread-dev libboost-program-options-dev libboost-system-dev libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libswresample-dev libmygui-dev libunshield-dev cmake build-essential libqt4-opengl-dev g++ libncurses5-dev #llvm-3.5 clang-3.5 libclang-3.5-dev llvm-3.5-dev libbullet-dev
      sudo apt-get build-dep bullet
      BUILD_BULLET=true
  ;;

  "fedora" )
      echo -e "You seem to be running Fedora"
      echo -e "\nFedora users are required to enable the RPMFusion FREE and NON-FREE repositories\nhttps://wiki.openmw.org/index.php?title=Development_Environment_Setup#Fedora_Workstation\n\nType YES if you want the script to do it automatically\nIf you already have it enabled or want to do it manually,\npress ENTER to continue"
      read INPUT
      if [ "$INPUT" == "YES" ]; then
            echo -e "\nEnabling RPMFusion..."
            su -c 'dnf install http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm'
            echo -e "Done!"
      fi
      sudo dnf --refresh groupinstall development-tools 
      sudo dnf --refresh install openal-devel OpenSceneGraph-qt-devel SDL2-devel qt4-devel boost-filesystem git boost-thread boost-program-options boost-system ffmpeg-devel ffmpeg-libs bullet-devel gcc-c++ mygui-devel unshield-devel tinyxml-devel cmake #llvm35 llvm clang ncurses
      BUILD_BULLET=true
  ;;

  *)
      echo -e "Could not determine your GNU/Linux distro, press ENTER to continue without installing dependencies"
      read
  ;;
esac
    
#PULL SOFTWARE VIA GIT
echo -e "\n>> Downloading software"
git clone https://github.com/TES3MP/openmw-tes3mp.git "$CODE"
if [ $BUILD_OSG ]; then git clone https://github.com/openscenegraph/OpenSceneGraph.git "$DEPENDENCIES"/osg; fi
if [ $BUILD_BULLET ]; then git clone https://github.com/bulletphysics/bullet3.git "$DEPENDENCIES"/bullet; fi
git clone https://github.com/TES3MP/RakNet.git "$DEPENDENCIES"/raknet
if [ $BUILD_TERRA ]; then git clone https://github.com/zdevito/terra.git "$DEPENDENCIES"/terra; else wget https://github.com/zdevito/terra/releases/download/release-2016-02-26/terra-Linux-x86_64-2fa8d0a.zip -O "$DEPENDENCIES"/terra.zip; fi
git clone https://github.com/TES3MP/PluginExamples.git "$KEEPERS"/PluginExamples

#COPY STATIC SERVER AND CLIENT CONFIGS
echo -e "\n>> Copying server and client configs to their permanent place"
cp "$CODE"/files/tes3mp/tes3mp-{client,server}-default.cfg "$KEEPERS"

#SET home VARIABLE IN tes3mp-server-default.cfg
echo -e "\n>> Autoconfiguring"
sed -i "s|~/ClionProjects/PS-dev|$KEEPERS/PluginExamples|g" $KEEPERS/tes3mp-server-default.cfg

#DIRTY HACKS
echo -e "\n>> Applying some dirty hacks"
sed -i "s|tes3mp.lua,chat_parser.lua|server.lua|g" $KEEPERS/tes3mp-server-default.cfg #Fixes server scripts
sed -i "s|Y #key for switch chat mode enabled/hidden/disabled|Right Alt|g" $KEEPERS/tes3mp-client-default.cfg #Changes the chat key
#sed -i "s|mp.tes3mp.com|grimkriegor.zalkeen.us|g" $KEEPERS/tes3mp-client-default.cfg #Sets Grim's server as the default
USE_CXX14=true #Forces the use of C++14

#BUILD OPENSCENEGRAPH
if [ $BUILD_OSG ]; then
    echo -e "\n>> Building OpenSceneGraph"
    mkdir "$DEPENDENCIES"/osg/build
    cd "$DEPENDENCIES"/osg/build
    git checkout tags/OpenSceneGraph-3.4.0
    rm CMakeCache.txt
    cmake ..
    make -j$CORES

    cd "$BASE"
fi

#BUILD BULLET
if [ $BUILD_BULLET ]; then
    echo -e "\n>> Building Bullet Physics"
    mkdir "$DEPENDENCIES"/bullet/build
    cd "$DEPENDENCIES"/bullet/build
    git checkout tags/2.86
    rm CMakeCache.txt
    cmake -DCMAKE_INSTALL_PREFIX="$DEPENDENCIES"/bullet/install -DBUILD_SHARED_LIBS=1 -DINSTALL_LIBS=1 -DINSTALL_EXTRA_LIBS=1 -DCMAKE_BUILD_TYPE=Release ..
    make -j$CORES
    make install
    
    cd "$BASE"
fi

#BUILD RAKNET
echo -e "\n>> Building RakNet"
mkdir "$DEPENDENCIES"/raknet/build
cd "$DEPENDENCIES"/raknet/build
rm CMakeCache.txt
cmake -DCMAKE_BUILD_TYPE=Release -DRAKNET_ENABLE_DLL=OFF -DRAKNET_ENABLE_SAMPLES=OFF -DRAKNET_ENABLE_STATIC=ON -DRAKNET_GENERATE_INCLUDE_ONLY_DIR=ON ..
make -j$CORES
ln -s "$DEPENDENCIES"/raknet/include/RakNet "$DEPENDENCIES"/raknet/include/raknet #Stop being so case sensitive

cd "$BASE"

#BUILD TERRA
if [ $BUILD_TERRA ]; then
    echo -e "\n>> Building Terra"
    cd $DEPENDENCIES/terra/
    make -j$CORES
else
    echo -e "\n>> Unpacking and preparing Terra"
    cd "$DEPENDENCIES"
    unzip terra.zip
    mv terra-* terra
    rm terra.zip
fi

cd "$BASE"

#CALL upgrade.sh TO BUILD TES3MP
echo -e "\n>>Preparing to build TES3MP"
bash upgrade.sh "$CORES" --install

read

