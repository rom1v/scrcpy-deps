This project hosts a script to generate a minimal FFmpeg Windows build for
[scrcpy].

[scrcpy]: https://github.com/Genymobile/scrcpy

The script is intended to be executred on Linux (typically Debian), with
`mingw-w64` installed.

The packages `libz-mingw-w64` and `libz-mingw-w64-dev` (necessary for zlib) must
be installed.

First, clone the official FFmpeg project anywhere:

```
git clone git://source.ffmpeg.org/ffmpeg.git
```

Checkout the expected version.

Then, from this `scrcpy-deps` repo, run:

```
./build_ffmpeg_windows.sh <ffmpeg_directory>
```
