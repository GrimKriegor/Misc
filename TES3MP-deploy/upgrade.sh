#!/bin/bash

CORES=5

BASE="$(pwd)"
CODE=$BASE/code
DEVELOPMENT=$BASE/build
KEEPERS=$BASE/keepers
DEPENDENCIES=$BASE/dependencies

RAKNET_LOCATION="$DEPENDENCIES/raknet"
TERRA_LOCATION="$DEPENDENCIES/terra/release/"

cd $CODE
git pull
cd $BASE

if [ "$1" = "--install" ]; then
  UPGRADE="YES"
else
  echo "Upgrade?"
  read UPGRADE
fi

if [ "$UPGRADE" = "YES" ]; then

  rm -r $DEVELOPMENT
  mkdir $DEVELOPMENT

  cd $DEVELOPMENT
  cmake $CODE -DBUILD_OPENCS=OFF -DRakNet_INCLUDES=${RAKNET_LOCATION}/include/RakNet -DRakNet_LIBRARY_DEBUG=${RAKNET_LOCATION}/build/Lib/LibStatic/libRakNetLibStatic.a -DRakNet_LIBRARY_RELEASE=${RAKNET_LOCATION}/build/Lib/LibStatic/libRakNetLibStatic.a -DTerra_LIBRARY_RELEASE=${TERRA_LOCATION}/lib/libterra.a -DTerra_INCLUDES=${TERRA_LOCATION}/include
  make -j $CORES

fi

for file in $KEEPERS/*
do
  FILEPATH=$file
  FILENAME=$(basename $file)
    echo "KEEPERS -> $FILENAME"
    mv "$DEVELOPMENT/$FILENAME" "$DEVELOPMENT/$FILENAME.bkp"
    ln -s "$KEEPERS/$FILENAME" "$DEVELOPMENT/"
done

read
