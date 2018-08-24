# VLCMediaLibraryKit

VLCMediaLibraryKit is a wrapper of the [VideoLAN medialibrary][1] in Objective-C/C++.

## Installation

## Cocoapods

To integrate VLCMediaLibraryKit into your project, specify it in your Podfile:

`pod 'VLCMediaLibraryKit'`

Then, run the following command:

`pod install`

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
    -p      VLCKit path(default is ~/)
```


In able to build VLCMediaLibraryKit, you **need** [VLCKit][2] compiled for the architecture you want to build.
By default, if `-p SPECIFIC_PATH_TO_VLCKIT` is not passed to the build script, it will try to find VLCKit starting from the user home directory.


**Example:**

`./buildVLCMediaLibraryKit.sh -vc`

`./buildVLCMediaLibraryKit.sh -vdca aarch64`

`./buildVLCMediaLibraryKit.sh -vdca x86_64 -p SPECIFIC_PATH_TO_VLCKIT`

After a successfull build, a `VLCMediaLibraryKit.framework` can be found in the `build` directory.

[1]: https://code.videolan.org/videolan/medialibrary
[2]: https://code.videolan.org/videolan/VLCKit
