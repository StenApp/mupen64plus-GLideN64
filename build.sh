#!/usr/bin/env bash

install_dir=$PWD/mupen64plus
mkdir $install_dir
base_dir=$PWD
cd mupen64plus-core/projects/unix
make -j4 all
cp -P $base_dir/mupen64plus-core/projects/unix/lib* $install_dir
cp $base_dir/mupen64plus-core/data/* $install_dir
cd $base_dir/mupen64plus-rsp-hle/projects/unix
make -j4 all
cp $base_dir/mupen64plus-rsp-hle/projects/unix/mupen64plus-rsp-hle.so $install_dir
cd $base_dir/mupen64plus-rsp-cxd4/projects/unix
make -j4 all
cp $base_dir/mupen64plus-rsp-cxd4/projects/unix/mupen64plus-rsp-cxd4*.so $install_dir
cd $base_dir/mupen64plus-input-sdl/projects/unix
make -j4 all
cp $base_dir/mupen64plus-input-sdl/projects/unix/mupen64plus-input-sdl.so $install_dir
cp $base_dir/mupen64plus-input-sdl/data/* $install_dir
cd $base_dir/mupen64plus-audio-sdl/projects/unix
make -j4 all
cp $base_dir/mupen64plus-audio-sdl/projects/unix/mupen64plus-audio-sdl.so $install_dir
cd $base_dir/mupen64plus-ui-console/projects/unix
make -j4 all
cp $base_dir/mupen64plus-ui-console/projects/unix/mupen64plus $install_dir
cd $base_dir/GLideN64/src
./getRevision.sh
cd $base_dir/GLideN64/projects/cmake
cmake -DMUPENPLUSAPI=On ../../src/
make -j4
cp plugin/release/mupen64plus-video-GLideN64.so $install_dir
cp $base_dir/GLideN64/ini/GLideN64.custom.ini $install_dir
cd $base_dir
