#!/bin/bash

#PARSE ARGUMENTS
while [ $# -ne 0 ]; do
  case $1 in

  #NUMBER OF CPU THREADS
  -c | --cores )
    ARG_CORES=$2
    shift
  ;;

  #FIRST TIME RUN, INSTALL WITHOUT ASKING
  -i | --install )
    INSTALL=true
  ;;

  #UPGRADE IF THERE ARE CHANGES IN THE UPSTREAM CODE
  -u | --check-changes )
    CHECK_CHANGES=true
  ;;

  esac
  shift

done

#NUMBER OF CPU CORES USED FOR COMPILATION
if [[ "$ARG_CORES" == "" || "$ARG_CORES" == "0" ]]; then
    CORES="$(cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l)"
else
    CORES="$ARG_CORES"
fi

#FOLDER HIERARCHY
BASE="$(pwd)"
CODE="$BASE/code"
DEVELOPMENT="$BASE/build"
KEEPERS="$BASE/keepers"
DEPENDENCIES="$BASE/dependencies"

if [ -d "$DEPENDENCIES"/osg ]; then
  BUILD_OSG=true
fi

if [ -d "$DEPENDENCIES"/bullet ]; then
  BUILD_BULLET=true
fi

if [ -f "$BASE"/serveronly ]; then
  SERVER_ONLY=true
fi

#DEPENDENCY LOCATIONS
CALLFF_LOCATION="$DEPENDENCIES"/callff
RAKNET_LOCATION="$DEPENDENCIES"/raknet
TERRA_LOCATION="$DEPENDENCIES"/terra
if [ $BUILD_OSG ]; then OSG_LOCATION="$DEPENDENCIES"/osg; fi
if [ $BUILD_BULLET ]; then BULLET_LOCATION="$DEPENDENCIES"/bullet; fi

#CHECK IF THERE ARE CHANGES IN THE GIT REMOTE
echo -e "\n>> Checking the git repository for changes"
cd "$CODE"
#git pull --dry-run | grep -q -v 'Already up-to-date.'
git remote update
test $(git rev-parse @) != $(git rev-parse @{u})
if [ $? -eq 0 ]; then
  echo -e "\nNEW CHANGES on the git repository"
  GIT_CHANGES=true
else
  echo -e "\nNo changes on the git repository"
fi
cd "$BASE"

#OPTION TO UPGRADE
if [ $INSTALL ]; then
  UPGRADE="YES"
elif [ $CHECK_CHANGES ]; then
  if [ $GIT_CHANGES ]; then
    UPGRADE="YES"
  else
    echo -e "\nNo new commits, exiting."
    exit 0
  fi
else
  echo -e "\nDo you wish to rebuild TES3MP? (type YES to continue)"
  read UPGRADE
fi

#REBUILD OPENMW/TES3MP
if [ "$UPGRADE" = "YES" ]; then

  #PULL CODE CHANGES FROM THE GIT REPOSITORY
  echo -e "\n>> Pulling code changes from git"
  cd "$CODE"
  git pull
  cd "$BASE"

  echo -e "\n>> Doing a clean build of TES3MP"

  rm -r "$DEVELOPMENT"
  mkdir "$DEVELOPMENT"

  cd "$DEVELOPMENT"

  CMAKE_PARAMS="-DBUILD_OPENCS=OFF \
      -DCMAKE_CXX_STANDARD=14 \
      -DCMAKE_CXX_FLAGS=\"-std=c++14\" \
      -DCallFF_INCLUDES="${CALLFF_LOCATION}"/include \
      -DCallFF_LIBRARY="${CALLFF_LOCATION}"/build/src/libcallff.a \
      -DRakNet_INCLUDES="${RAKNET_LOCATION}"/include \
      -DRakNet_LIBRARY_DEBUG="${RAKNET_LOCATION}"/build/lib/LibStatic/libRakNetLibStatic.a \
      -DRakNet_LIBRARY_RELEASE="${RAKNET_LOCATION}"/build/lib/LibStatic/libRakNetLibStatic.a \
      -DTerra_INCLUDES="${TERRA_LOCATION}"/include \
      -DTerra_LIBRARY_RELEASE="${TERRA_LOCATION}"/lib/libterra.a"

  if [ $BUILD_OSG ]; then
    CMAKE_PARAMS="$CMAKE_PARAMS \
      -DOPENTHREADS_INCLUDE_DIR="${OSG_LOCATION}"/include \
      -DOPENTHREADS_LIBRARY="${OSG_LOCATION}"/build/lib/libOpenThreads.so \
      -DOSG_INCLUDE_DIR="${OSG_LOCATION}"/include \
      -DOSG_LIBRARY="${OSG_LOCATION}"/build/lib/libosg.so \
      -DOSGANIMATION_INCLUDE_DIR="${OSG_LOCATION}"/include \
      -DOSGANIMATION_LIBRARY="${OSG_LOCATION}"/build/lib/libosgAnimation.so \
      -DOSGDB_INCLUDE_DIR="${OSG_LOCATION}"/include \
      -DOSGDB_LIBRARY="${OSG_LOCATION}"/build/lib/libosgDB.so \
      -DOSGFX_INCLUDE_DIR="${OSG_LOCATION}"/include \
      -DOSGFX_LIBRARY="${OSG_LOCATION}"/build/lib/libosgFX.so \
      -DOSGGA_INCLUDE_DIR="${OSG_LOCATION}"/include \
      -DOSGGA_LIBRARY="${OSG_LOCATION}"/build/lib/libosgGA.so \
      -DOSGPARTICLE_INCLUDE_DIR="${OSG_LOCATION}"/include \
      -DOSGPARTICLE_LIBRARY="${OSG_LOCATION}"/build/lib/libosgParticle.so \
      -DOSGTEXT_INCLUDE_DIR="${OSG_LOCATION}"/include \
      -DOSGTEXT_LIBRARY="${OSG_LOCATION}"/build/lib/libosgText.so\
      -DOSGUTIL_INCLUDE_DIR="${OSG_LOCATION}"/include \
      -DOSGUTIL_LIBRARY="${OSG_LOCATION}"/build/lib/libosgUtil.so \
      -DOSGVIEWER_INCLUDE_DIR="${OSG_LOCATION}"/include \
      -DOSGVIEWER_LIBRARY="${OSG_LOCATION}"/build/lib/libosgViewer.so"
  fi
  
  if [ $BUILD_BULLET ]; then
    CMAKE_PARAMS="$CMAKE_PARAMS \
      -DBullet_INCLUDE_DIR="${BULLET_LOCATION}"/install/include/bullet \
      -DBullet_BulletCollision_LIBRARY="${BULLET_LOCATION}"/install/lib/libBulletCollision.so \
      -DBullet_LinearMath_LIBRARY="${BULLET_LOCATION}"/install/lib/libLinearMath.so"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH":"${BULLET_LOCATION}"/install/lib
    export BULLET_ROOT="${BULLET_LOCATION}"/install
  fi

  if [ $SERVER_ONLY ]; then
    CMAKE_PARAMS="$CMAKE_PARAMS \
      -DBUILD_OPENMW_MP=ON \
      -DBUILD_BROWSER=OFF \
      -DBUILD_BSATOOL=OFF \
      -DBUILD_ESMTOOL=OFF \
      -DBUILD_ESSIMPORTER=OFF \
      -DBUILD_LAUNCHER=OFF \
      -DBUILD_MWINIIMPORTER=OFF \
      -DBUILD_MYGUI_PLUGIN=OFF \
      -DBUILD_OPENMW=OFF \
      -DBUILD_WIZARD=OFF"
  fi

  echo -e "\n\n$CMAKE_PARAMS\n\n"
  cmake "$CODE" $CMAKE_PARAMS
  make -j $CORES 2>&1 | tee "${BASE}"/build.log

fi

cd "$BASE"

#CREATE SYMLINKS FOR THE CONFIG FILES INSIDE THE NEW BUILD FOLDER
echo -e "\n>> Creating symlinks of the config files in the build folder"
for file in "$KEEPERS"/*
do
  FILEPATH=$file
  FILENAME=$(basename $file)
    mv "$DEVELOPMENT/$FILENAME" "$DEVELOPMENT/$FILENAME.bkp" 2> /dev/null
    ln -s "$KEEPERS/$FILENAME" "$DEVELOPMENT/"
done

#CREATE SYMLINKS FOR RESOURCES INSIDE THE CONFIG FOLDER
echo -e "\n>> Creating symlinks for resources inside the config folder"
ln -s "$DEVELOPMENT"/resources "$KEEPERS"/resources 2> /dev/null

#CREATE USEFUL SHORTCUTS ON THE BASE DIRECTORY
echo -e "\n>> Creating useful shortcuts on the base directory"
if [ $SERVER_ONLY ]; then
  SHORTCUTS=( "tes3mp-server" )
else
  SHORTCUTS=( "tes3mp" "tes3mp-browser" "tes3mp-server" )
fi
for i in ${SHORTCUTS[@]}; do
  printf "#!/bin/bash\n\ncd build/\n./$i\ncd .." > "$i".sh
  chmod +x "$i".sh
done

#ALL DONE
echo -e "\n\n\nAll done! Press any key to exit.\nMay Vehk bestow his blessing upon your Muatra."
read
