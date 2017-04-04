#!/usr/bin/env bash

if [[ $1 == "rpi3" ]]; then
  export CFLAGS="-O2 -march=armv8-a+crc -mtune=cortex-a53 -mfpu=neon-fp-armv8 -mfloat-abi=hard -ftree-vectorize -funsafe-math-optimizations"
  export CXXFLAGS=$CFLAGS
  export VC=1
  export USE_GLES=1
  export NEON=1
  export VFP_HARD=1
fi

UNAME=$(uname -s)
if [[ $UNAME == *"MINGW"* ]]; then
  suffix=".dll"
else
  suffix=".so"
fi

install_dir=$PWD/mupen64plus
mkdir $install_dir
base_dir=$PWD

cd $base_dir/mupen64plus-core/projects/unix
make -j4 all
cp -P $base_dir/mupen64plus-core/projects/unix/*$suffix* $install_dir
cp $base_dir/mupen64plus-core/data/* $install_dir

cd $base_dir/mupen64plus-rsp-hle/projects/unix
make -j4 all
cp $base_dir/mupen64plus-rsp-hle/projects/unix/*$suffix $install_dir

if [[ $1 != "rpi3" ]]; then
  cd $base_dir/mupen64plus-rsp-cxd4/projects/unix
  make -j4 all
  cp $base_dir/mupen64plus-rsp-cxd4/projects/unix/*$suffix $install_dir
fi

cd $base_dir/mupen64plus-input-sdl/projects/unix
make -j4 all
cp $base_dir/mupen64plus-input-sdl/projects/unix/*$suffix $install_dir
cp $base_dir/mupen64plus-input-sdl/data/* $install_dir

cd $base_dir/mupen64plus-audio-sdl/projects/unix
make -j4 all
cp $base_dir/mupen64plus-audio-sdl/projects/unix/*$suffix $install_dir

cd $base_dir/mupen64plus-ui-console/projects/unix
make -j4 all
cp $base_dir/mupen64plus-ui-console/projects/unix/mupen64plus* $install_dir

if [[ $1 != "rpi3" ]]; then
  mkdir -p $base_dir/mupen64plus-gui/build
  cd $base_dir/mupen64plus-gui/build
  if [[ $UNAME == *"MINGW"* ]]; then
    /mingw64/qt5-static/bin/qmake ../mupen64plus-gui.pro
    make -j4 release
    cp $base_dir/mupen64plus-gui/build/release/mupen64plus-gui.exe $install_dir
  else
    qmake ../mupen64plus-gui.pro
    make -j4
    cp $base_dir/mupen64plus-gui/build/mupen64plus-gui $install_dir
  fi
fi

cd $base_dir/GLideN64/src
./getRevision.sh
cd $base_dir/GLideN64/projects/cmake
if [[ $1 == "rpi3" ]]; then
  cmake -DNOHQ=On -DCRC_ARMV8=On -DNEON_OPT=On -DVEC4_OPT=On -DMUPENPLUSAPI=On ../../src/
elif [[ $UNAME == *"MINGW"* ]]; then
  cmake -G "MSYS Makefiles" -DVEC4_OPT=On -DCRC_OPT=On -DMUPENPLUSAPI=On ../../src/
else
  cmake -DVEC4_OPT=On -DCRC_OPT=On -DMUPENPLUSAPI=On ../../src/
fi
make -j4

if [[ $UNAME == *"MINGW"* ]]; then
  cp mupen64plus-video-GLideN64.dll $install_dir
else
  cp plugin/release/mupen64plus-video-GLideN64.so $install_dir
fi
cp $base_dir/GLideN64/ini/GLideN64.custom.ini $install_dir
cd $base_dir

my_date=$(date +'%Y%m')
if [[ $UNAME == *"MINGW"* ]]; then
  my_os=win64
  cp /mingw64/bin/libgcc_s_seh-1.dll $install_dir
  cp /mingw64/bin/libwinpthread-1.dll $install_dir
  cp /mingw64/bin/SDL2.dll $install_dir
  cp /mingw64/bin/libpcre16-0.dll $install_dir
  cp /mingw64/bin/libpng16-16.dll $install_dir
  cp /mingw64/bin/libglib-2.0-0.dll $install_dir
  cp /mingw64/bin/libstdc++-6.dll $install_dir
  cp /mingw64/bin/zlib1.dll $install_dir
  cp /mingw64/bin/libintl-8.dll $install_dir
  cp /mingw64/bin/libpcre-1.dll $install_dir
  cp /mingw64/bin/libiconv-2.dll $install_dir
  cp /mingw64/bin/libharfbuzz-0.dll $install_dir
  cp /mingw64/bin/libgraphite2.dll $install_dir
  cp /mingw64/bin/libfreetype-6.dll $install_dir
  cp /mingw64/bin/libbz2-1.dll $install_dir
  cp /mingw64/bin/libminizip-1.dll $install_dir
  cp /mingw64/bin/libsamplerate-0.dll $install_dir
  cp /mingw64/bin/libspeexdsp-1.dll $install_dir
  cp /mingw64/bin/libjasper-4.dll $install_dir
  cp /mingw64/bin/libjpeg-8.dll $install_dir
else
  my_os=linux
fi

if [[ $1 == "aws" ]]; then
  rm $base_dir/*.zip
  zip -r mupen64plus-GLideN64-$my_os-$my_date.zip mupen64plus
  aws s3 cp mupen64plus-GLideN64-*.zip s3://m64p/m64p/ --acl public-read
fi
