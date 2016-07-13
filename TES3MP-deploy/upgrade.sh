#!/bin/bash

CORES=5

BASE="$(pwd)"
CODE=$BASE/code
DEVELOPMENT=$BASE/build
KEEPERS=$BASE/keepers
DEPENDENCIES=$BASE/dependencies

RAKNET_LOCATION="$DEPENDENCIES/raknet"
TERRA_LOCATION="$DEPENDENCIES/terra"

cd $CODE
git pull
cd $BASE

echo "Upgrade?"
read UPGRADE

if [ "$UPGRADE" = "YES" ]; then

  rm -r $DEVELOPMENT
  mkdir $DEVELOPMENT

  cd $DEVELOPMENT
  cmake $CODE -DBUILD_OPENCS=OFF -DRakNet_INCLUDES=${RAKNET_LOCATION}/include/RakNet -DRakNet_LIBRARY_DEBUG=${RAKNET_LOCATION}/build/Lib/LibStatic/libRakNetLibStatic.a -DRakNet_LIBRARY_RELEASE=${RAKNET_LOCATION}/build/Lib/LibStatic/libRakNetLibStatic.a
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
