#!/usr/bin/env bash

UNAME=$(uname -s)
if [[ $UNAME == *"MINGW"* ]]; then
  suffix=".dll"
  if [[ $UNAME == *"MINGW64"* ]]; then
    mingw_prefix="mingw64"
  else
    mingw_prefix="mingw32"
  fi
elif [[ $UNAME == "Darwin" ]]; then
  suffix=".dylib"
else
  suffix=".so"
fi

#if [[ $HOST_CPU == "i686" ]]; then
#  export NEW_DYNAREC=1
#fi

install_dir=$PWD/mupen64plus
mkdir $install_dir
base_dir=$PWD

echo "==Create mupen64plus-core=="
cd $base_dir/mupen64plus-core/projects/unix
make -j4 all
cp -P $base_dir/mupen64plus-core/projects/unix/*$suffix* $install_dir
cp $base_dir/mupen64plus-core/data/* $install_dir

echo "==Create mupen64plus-rsp-hle=="
cd $base_dir/mupen64plus-rsp-hle/projects/unix
make -j4 all
cp $base_dir/mupen64plus-rsp-hle/projects/unix/*$suffix $install_dir

echo "==Create mupen64plus-rsp-cxd=="
cd $base_dir/mupen64plus-rsp-cxd4/projects/unix
make HLEVIDEO=1 -j4 all
cp $base_dir/mupen64plus-rsp-cxd4/projects/unix/*$suffix $install_dir

echo "==Create mupen64plus-input-sdl=="
cd $base_dir/mupen64plus-input-sdl/projects/unix
make -j4 all
cp $base_dir/mupen64plus-input-sdl/projects/unix/*$suffix $install_dir
cp $base_dir/mupen64plus-input-sdl/data/* $install_dir

echo "==Create mupen64plus-audio-sdl2=="
cd $base_dir/mupen64plus-audio-sdl2/projects/unix
make -j4 all
cp $base_dir/mupen64plus-audio-sdl2/projects/unix/*$suffix $install_dir

echo "==Create mupen64plus-gui=="
mkdir -p $base_dir/mupen64plus-gui/build
cd $base_dir/mupen64plus-gui/build
if [[ $UNAME == *"MINGW"* ]]; then
  /$mingw_prefix/qt5-static/bin/qmake ../mupen64plus-gui.pro
  make -j4 release
  cp $base_dir/mupen64plus-gui/build/release/mupen64plus-gui.exe $install_dir
elif [[ $UNAME == "Darwin" ]]; then
  /usr/local/Cellar/qt/*/bin/qmake ../mupen64plus-gui.pro
  make -j4
  cp -Rp $base_dir/mupen64plus-gui/build/mupen64plus-gui.app $install_dir
else
  qmake ../mupen64plus-gui.pro
  make -j4
  cp $base_dir/mupen64plus-gui/build/mupen64plus-gui $install_dir
fi

echo "==Create GlideN64=="
cd $base_dir/GLideN64/src
./getRevision.sh
cd $base_dir/GLideN64/projects/cmake
if [[ $UNAME == *"MINGW"* ]]; then
  cmake -G "MSYS Makefiles" -DVEC4_OPT=On -DCRC_OPT=On -DMUPENPLUSAPI=On -DCMAKE_AR=/$mingw_prefix/bin/gcc-ar ../../src/
else
  cmake -DUSE_SYSTEM_LIBS=On -DVEC4_OPT=On -DCRC_OPT=On -DMUPENPLUSAPI=On ../../src/
fi
make -j4

echo "==Move ini files=="
if [[ $UNAME == *"MINGW"* ]]; then
  cp mupen64plus-video-GLideN64$suffix $install_dir
else
  cp plugin/release/mupen64plus-video-GLideN64$suffix $install_dir
fi
cp $base_dir/GLideN64/ini/GLideN64.custom.ini $install_dir

echo "==Create angrylion-rdp-plus=="
if [[ $UNAME == *"MINGW"* ]]; then
  cd $base_dir/angrylion-rdp-plus
  sed -i 's/python /python3 /g' core/core.vcxproj
  if [[ $UNAME == *"MINGW64"* ]]; then
    MSBuild.exe angrylion-plus.sln //t:plugin-mupen64plus //p:Configuration=Release //p:Platform=x64
  else
    MSBuild.exe angrylion-plus.sln //t:plugin-mupen64plus //p:Configuration=Release //p:Platform=x86
  fi
  cp $base_dir/angrylion-rdp-plus/build/Release/mupen64plus-video-angrylion-plus.dll $install_dir
else
  mkdir -p $base_dir/angrylion-rdp-plus/build
  cd $base_dir/angrylion-rdp-plus/build
  cmake ../
  make -j4
  cp mupen64plus-video-angrylion-plus$suffix $install_dir
fi

echo "==Bundle the files=="
cd $base_dir

if [[ $UNAME == *"MINGW"* ]]; then
  if [[ $UNAME == *"MINGW64"* ]]; then
    my_os=win64
    cp /$mingw_prefix/bin/libgcc_s_seh-1.dll $install_dir
  else
    my_os=win32
    cp /$mingw_prefix/bin/libgcc_s_dw2-1.dll $install_dir
  fi
  cp /$mingw_prefix/bin/libwinpthread-1.dll $install_dir
  cp /$mingw_prefix/bin/SDL2.dll $install_dir
  cp /$mingw_prefix/bin/libpng16-16.dll $install_dir
  cp /$mingw_prefix/bin/libglib-2.0-0.dll $install_dir
  cp /$mingw_prefix/bin/libstdc++-6.dll $install_dir
  cp /$mingw_prefix/bin/zlib1.dll $install_dir
  cp /$mingw_prefix/bin/libintl-8.dll $install_dir
  cp /$mingw_prefix/bin/libpcre-1.dll $install_dir
  cp /$mingw_prefix/bin/libiconv-2.dll $install_dir
  cp /$mingw_prefix/bin/libharfbuzz-0.dll $install_dir
  cp /$mingw_prefix/bin/libgraphite2.dll $install_dir
  cp /$mingw_prefix/bin/libfreetype-6.dll $install_dir
  cp /$mingw_prefix/bin/libbz2-1.dll $install_dir
  cp /$mingw_prefix/bin/libminizip-1.dll $install_dir
  cp /$mingw_prefix/bin/libsamplerate-0.dll $install_dir
  cp /$mingw_prefix/bin/libjasper-4.dll $install_dir
  cp /$mingw_prefix/bin/libjpeg-8.dll $install_dir
  cp $base_dir/7za.exe $install_dir
elif [[ $UNAME == "Darwin" ]]; then
  my_os=macos

  mkdir -p mupen64plus/mupen64plus-gui.app/Contents/Frameworks
  find . -name "mupen64plus*.dylib" -depth 1 \
 -exec mv {} mupen64plus/mupen64plus-gui.app/Contents/Frameworks/ \;

  mkdir -p mupen64plus/mupen64plus-gui.app/Contents/Resources
  find . -type f -depth 1 \
 -exec mv {} mupen64plus/mupen64plus-gui.app/Contents/Resources/ \;


  cd $install_dir
  /usr/local/Cellar/qt/*/bin/macdeployqt mupen64plus-gui.app

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
