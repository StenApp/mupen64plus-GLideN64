#!/usr/bin/env bash

if [[ $1 == "rpi3" ]]; then
  export CFLAGS="-O3 -march=armv8-a+crc -mtune=cortex-a53 -mfpu=neon-fp-armv8 -mfloat-abi=hard"
  export CXXFLAGS=$CFLAGS
  export USE_GLES=1
  export NEON=1
  export VFP_HARD=1
fi

UNAME=$(uname -s)
if [[ $UNAME == *"MINGW"* ]]; then
  suffix=".dll"
elif [[ $UNAME == "Darwin" ]]; then
  suffix=".dylib"
else
  if [[ $HOST_CPU != "i686" ]]; then
    if [[ $1 != "rpi3" ]]; then
      export PIE=1
    fi
  fi
  suffix=".so"
fi

#if [[ $HOST_CPU == "i686" ]]; then
#  export NEW_DYNAREC=1
#fi

install_dir=$PWD/mupen64plus
mkdir $install_dir
base_dir=$PWD

cd $base_dir/mupen64plus-core/projects/unix
make -j4 all
cp -P $base_dir/mupen64plus-core/projects/unix/*$suffix* $install_dir
cp $base_dir/mupen64plus-core/data/* $install_dir

if [[ $1 != "rpi3" ]]; then
  cd $base_dir/mupen64plus-rsp-cxd4/projects/unix
  make HLEVIDEO=1 -j4 all
  cp $base_dir/mupen64plus-rsp-cxd4/projects/unix/*$suffix $install_dir
else
  cd $base_dir/mupen64plus-rsp-hle/projects/unix
  make -j4 all
  cp $base_dir/mupen64plus-rsp-hle/projects/unix/*$suffix $install_dir
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
    if [[ $UNAME == *"MINGW64"* ]]; then
      /mingw64/qt5-static/bin/qmake ../mupen64plus-gui.pro
    else
      /mingw32/qt5-static/bin/qmake ../mupen64plus-gui.pro
    fi
    make -j4 release
    cp $base_dir/mupen64plus-gui/build/release/mupen64plus-gui.exe $install_dir
  elif [[ $UNAME == "Darwin" ]]; then
    /usr/local/Cellar/qt5/*/bin/qmake ../mupen64plus-gui.pro
    make -j4
    cp -Rp $base_dir/mupen64plus-gui/build/mupen64plus-gui.app $install_dir
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
  cmake -DNOHQ=On -DUSE_SYSTEM_LIBS=On -DCRC_OPT=On -DNEON_OPT=On -DVEC4_OPT=On -DMUPENPLUSAPI=On ../../src/
elif [[ $UNAME == *"MINGW"* ]]; then
  cmake -G "MSYS Makefiles" -DVEC4_OPT=On -DCRC_OPT=On -DMUPENPLUSAPI=On ../../src/
else
  cmake -DUSE_SYSTEM_LIBS=On -DVEC4_OPT=On -DCRC_OPT=On -DMUPENPLUSAPI=On ../../src/
fi
make -j4

if [[ $UNAME == *"MINGW"* ]]; then
  cp mupen64plus-video-GLideN64$suffix $install_dir
else
  cp plugin/release/mupen64plus-video-GLideN64$suffix $install_dir
fi
cp $base_dir/GLideN64/ini/GLideN64.custom.ini $install_dir

if [[ $UNAME == *"MINGW"* ]]; then
  cd $base_dir/angrylion-rdp-plus
  sed -i 's/python/python3/g' core/core.vcxproj
  if [[ $UNAME == *"MINGW64"* ]]; then
    MSBuild.exe angrylion-plus.sln //t:core //p:Configuration=Release //p:Platform=x64
    MSBuild.exe angrylion-plus.sln //t:plugin-mupen64plus //p:Configuration=Release //p:Platform=x64
  else
    MSBuild.exe angrylion-plus.sln //t:core //p:Configuration=Release //p:Platform=x86
    MSBuild.exe angrylion-plus.sln //t:plugin-mupen64plus //p:Configuration=Release //p:Platform=x86
  fi
  cp $base_dir/angrylion-rdp-plus/build/Release/mupen64plus-video-angrylionplus.dll $install_dir
else
  cd $base_dir/angrylion-rdp-plus/plugin-mupen64plus/projects/unix
  make -j4 all
  cp $base_dir/angrylion-rdp-plus/plugin-mupen64plus/projects/unix/*$suffix $install_dir
fi

cd $base_dir

if [[ $UNAME == *"MINGW"* ]]; then
  if [[ $UNAME == *"MINGW64"* ]]; then
    my_os=win64
    my_path=mingw64
    cp /$my_path/bin/libgcc_s_seh-1.dll $install_dir
  else
    my_os=win32
    my_path=mingw32
    cp /$my_path/bin/libgcc_s_dw2-1.dll $install_dir
  fi
  cp /$my_path/bin/libwinpthread-1.dll $install_dir
  cp /$my_path/bin/SDL2.dll $install_dir
  cp /$my_path/bin/libpcre16-0.dll $install_dir
  cp /$my_path/bin/libpng16-16.dll $install_dir
  cp /$my_path/bin/libglib-2.0-0.dll $install_dir
  cp /$my_path/bin/libstdc++-6.dll $install_dir
  cp /$my_path/bin/zlib1.dll $install_dir
  cp /$my_path/bin/libintl-8.dll $install_dir
  cp /$my_path/bin/libpcre-1.dll $install_dir
  cp /$my_path/bin/libiconv-2.dll $install_dir
  cp /$my_path/bin/libharfbuzz-0.dll $install_dir
  cp /$my_path/bin/libgraphite2.dll $install_dir
  cp /$my_path/bin/libfreetype-6.dll $install_dir
  cp /$my_path/bin/libbz2-1.dll $install_dir
  cp /$my_path/bin/libminizip-1.dll $install_dir
  cp /$my_path/bin/libsamplerate-0.dll $install_dir
  cp /$my_path/bin/libspeexdsp-1.dll $install_dir
  cp /$my_path/bin/libjasper-4.dll $install_dir
  cp /$my_path/bin/libjpeg-8.dll $install_dir
elif [[ $UNAME == "Darwin" ]]; then
  my_os=macos

  find mupen64plus -type f -depth 1 \
    -exec mv {} mupen64plus/mupen64plus-gui.app/Contents/MacOS/ \;

  cd $install_dir
  /usr/local/Cellar/qt5/*/bin/macdeployqt mupen64plus-gui.app

  for P in $(find mupen64plus-gui.app -type f -name 'Qt*'; find mupen64plus-gui.app -type f -name '*.dylib'); do
    for P1 in $(otool -L $P | awk '/\/usr\/local\/Cellar/ {print $1}'); do
      PATHNAME=$(echo $P1 | awk '{sub(/(\/Qt.+\.framework|[^\/]*\.dylib).*/, ""); print}')
      PSLASH1=$(echo $P1 | sed "s,$PATHNAME,@executable_path/../Frameworks,g")
      install_name_tool -change $P1 $PSLASH1 $P
    done
  done

  cd $base_dir
else
  if [[ $HOST_CPU == "i686" ]]; then
    my_os=linux32
  else
    my_os=linux64
  fi
fi

if [[ $1 == "aws" ]]; then
  rm $base_dir/*.zip
  zip -r mupen64plus-GLideN64-$my_os.zip mupen64plus
  aws s3 cp mupen64plus-GLideN64-*.zip s3://m64p/m64p/ --acl public-read
fi
