#!/usr/bin/env bash

base_dir=$PWD
cd mupen64plus-core/projects/unix
make clean
cd $base_dir/mupen64plus-rsp-hle/projects/unix
make clean
cd $base_dir/mupen64plus-rsp-cxd4/projects/unix
make clean
cd $base_dir/mupen64plus-input-sdl/projects/unix
make clean
cd $base_dir/mupen64plus-audio-sdl/projects/unix
make clean
cd $base_dir/mupen64plus-ui-console/projects/unix
make clean
cd $base_dir/GLideN64/projects/cmake
make clean
cd $base_dir
rm -rf $base_dir/mupen64plus
