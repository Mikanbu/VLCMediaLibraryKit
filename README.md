# VLCMediaLibraryKit

This is an experimental version of MediaLibraryKit created for [GSoC 2017 with VideoLAN][2].

This version includes the usage of the [VideoLAN medialibrary][1] written by Hugo Beauzée-Luyssen.
Therefore changing the whole structure of MLKit.

## Installation

For now this version is available either using CocoaPods or manual installation.

### Manually

`git clone git@github.com:Mikanbu/VLCMediaLibraryKit.git`

## Building

A build script named `buildVLCMediaLibraryKit.sh` is available on the repository.

**Usage:**

```
    -v      Be more verbose
    -d      Enable debug mode
    -m      Skip medialibrary compilation
    -n      Skip script steps requiring network interaction
    -c      Clean all target build
    -s      Enable medialibrary build for simulators
    -x      Skip medialibrary dependencies build
    -a      Build for specific architecture(all|i386|x86_64|armv7|armv7s|aarch64)
```

**Example:**

`./buildVLCMediaLibraryKit.sh -vc`

`./buildVLCMediaLibraryKit.sh -vca aarch64`

After a successfull build, a `VLCMediaLibraryKit.framework` should be found in the `build` directory.

[1]: https://code.videolan.org/videolan/medialibrary
[2]: https://summerofcode.withgoogle.com/projects/#6366563499245568
