#!/bin/bash
set -e

if [[ $# -lt 1 ]]
then
    echo "Syntax: $0 <ffmpeg_directory>" >&2
    exit 1
fi

FFMPEG_DIRECTORY="$1"

configure_ffmpeg() {
    # -static-libgcc to avoid missing libgcc_s_dw2-1.dll
    # -static to avoid dynamic dependency to zlib
    CFLAGS='-static-libgcc -static' \
    LDFLAGS='-static-libgcc -static' \
    "$FFMPEG_DIRECTORY"/configure \
        --prefix=install \
        --enable-cross-compile \
        --target-os=mingw32 \
        --arch="$ARCH" \
        --cross-prefix="$CROSS_PREFIX" \
        --cc="${CROSS_PREFIX}gcc" \
        --extra-cflags="-O2 -fPIC" \
        --enable-shared \
        --disable-static \
        --disable-programs \
        --disable-doc \
        --disable-swscale \
        --disable-postproc \
        --disable-avfilter \
        --disable-avdevice \
        --disable-network \
        --disable-everything \
        --enable-swresample \
        --enable-decoder=h264 \
        --enable-decoder=hevc \
        --enable-decoder=av1 \
        --enable-decoder=pcm_s16le \
        --enable-decoder=opus \
        --enable-decoder=aac \
        --enable-decoder=flac \
        --enable-decoder=png \
        --enable-protocol=file \
        --enable-demuxer=image2 \
        --enable-parser=png \
        --enable-zlib \
        --enable-muxer=matroska \
        --enable-muxer=mp4 \
        --enable-muxer=opus \
        --enable-muxer=flac \
        --disable-vulkan
}

configure_ffmpeg_win64() {
    ARCH=x86_64
    CROSS_PREFIX="x86_64-w64-mingw32-"
    configure_ffmpeg
}

configure_ffmpeg_win32() {
    ARCH=x86
    CROSS_PREFIX="i686-w64-mingw32-"
    configure_ffmpeg
}

build_install() {
    local ABI="$1"
    rm -rf build-"$ABI"
    mkdir build-"$ABI"
    cd build-"$ABI"
    configure_ffmpeg_"$ABI"
    make -j
    make install
    cd ..
}

copy_release_binaries() {
    local ABI="$1"
    mkdir -p "ffmpeg/$ABI/bin"
    for name in avutil-58 avcodec-60 avformat-60 swresample-4
    do
        cp "../build-$ABI/install/bin/$name.dll" "ffmpeg/$ABI/bin/"
    done
    cp -r "../build-$ABI/install/include" "ffmpeg/$ABI/"
}

mkdir -p ffmpeg
cd ffmpeg

build_install win64
build_install win32

mkdir -p release/ffmpeg
cd release

copy_release_binaries win64
copy_release_binaries win32

7z a ffmpeg-release.7z ffmpeg
echo "FFmpeg release written to $PWD/ffmpeg-release.7z"
