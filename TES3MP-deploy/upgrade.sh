#!/bin/bash

#NUMBER OF CPU CORES USED FOR COMPILATION
if [ "$1" == "" ]; then
    CORES=3
else
    CORES="$1"
fi

#FOLDER HIERARCHY
BASE="$(pwd)"
CODE="$BASE/code"
DEVELOPMENT="$BASE/build"
KEEPERS="$BASE/keepers"
DEPENDENCIES="$BASE/dependencies"

#LOCATIONS OF RAKNET AND TERRA
RAKNET_LOCATION="$DEPENDENCIES"/raknet
TERRA_LOCATION="$DEPENDENCIES"/terra

#PULL CODE CHANGES FROM GIT
echo -e "\n>> Pulling code changes from git"
cd "$CODE"
git pull
cd "$BASE"

#OPTION TO UPGRADE AFTER PULLING THE CHANGES FROM THE GIT REPOSITORY
if [ "$2" = "--install" ]; then
  UPGRADE="YES"
else
  echo -e "\nDo you wish the upgrade TES3MP? (type YES to continue)"
  read UPGRADE
fi

#REBUILD OPENMW/TES3MP
if [ "$UPGRADE" = "YES" ]; then
  echo -e "\n>> Doing a clean build of TES3MP"

  rm -r "$DEVELOPMENT"
  mkdir "$DEVELOPMENT"

  cd "$DEVELOPMENT"
  cmake "$CODE" -DBUILD_OPENCS=OFF -DRakNet_INCLUDES="${RAKNET_LOCATION}"/include/RakNet -DRakNet_LIBRARY_DEBUG="${RAKNET_LOCATION}"/build/Lib/LibStatic/libRakNetLibStatic.a -DRakNet_LIBRARY_RELEASE="${RAKNET_LOCATION}"/build/Lib/LibStatic/libRakNetLibStatic.a -DTerra_LIBRARY_RELEASE="${TERRA_LOCATION}"/lib/libterra.a -DTerra_INCLUDES="${TERRA_LOCATION}"/include
  make -j $CORES

fi

#CREATE SYMLINKS FOR THE CONFIG FILES INSIDE THE NEW BUILD FOLDER
echo -e "\n>> Creating symlinks of the config files in the build folder"
for file in "$KEEPERS"/*
do
  FILEPATH=$file
  FILENAME=$(basename $file)
    mv "$DEVELOPMENT/$FILENAME" "$DEVELOPMENT/$FILENAME.bkp" 2> /dev/null
    ln -s "$KEEPERS/$FILENAME" "$DEVELOPMENT/"
done

#ALL DONE
echo -e "\n\n\nAll done! Press any key to exit.\nMay Vehk bestow his blessing upon your Muatra."
read
