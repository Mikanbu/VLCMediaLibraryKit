# MediaLibraryKit

This is an experimental version of MediaLibraryKit for [GSoC 2017 with VideoLAN][2].

**Version 3.0**

The 3.0 version includes the usage of the [VideoLAN medialibrary][1] written by Hugo Beauzée-Luyssen.
Therefore changing the whole structure of MLKit.

## Installation

For now this version is available either using CocoaPods or manual installation.

### CocoaPods

`pod 'MediaLibraryKit-unstable', :git => 'git://github.com/TheHungryBu/MediaLibraryKit.git', :branch => 'unstable'`

### Manually

`git clone git@github.com:TheHungryBu/MediaLibraryKit.git`

## Building

A build script named `buildMediaLibraryKit.sh` is available on the repository.

**Usage:**

```
    -v      Be more verbose
    -d      Enable debug mode
    -m      Skip medialibrary compilation
    -c      Clean all target build
    -s      Enable medialibrary build for simulators
    -x      Skip medialibrary dependencies build
```

**Example:**

`./buildMediaLibraryKit.sh -vc`

After a successfull building, a `MediaLibraryKit.framework` should be found in the `build` directory.

**Notes:**

Currently build by default for the following architectures:

```
* armv7
* armv7s
* aarch64
```

Please use the `-s` option to enable in addition of previously said architecture the build for the following architectures:

```
* i386
* x86_64
```

## Warning

This version of the MLKit repository contains a `build` directory only to facilitate the deployment using Cocoapods.


[1]: https://code.videolan.org/videolan/medialibrary
[2]: https://summerofcode.withgoogle.com/projects/#6366563499245568