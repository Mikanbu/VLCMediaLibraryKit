#!/bin/sh

ARCH="all"
CLEAN=no
SDK_MIN=9.0
VERBOSE=no
ROOT_DIR=default
SIMULATOR=no
NO_NETWORK=no
BUILD_TYPE="Release"
TESTED_HASH="f624aad5"
VLCKIT_PATH=~
BUILD_VLCKIT=no
SDK_VERSION=`xcrun --sdk iphoneos --show-sdk-version`
CXX_COMPILATOR=clang++
SKIP_MEDIALIBRARY=no
SKIP_DEPENDENCIES=no
OBJCXX_COMPILATOR=clang++
OSVERSIONMINCFLAG=mios
OSVERSIONMINLDFLAG=ios
BUILTJPEGLIBSSIM=
BUILTJPEGLIBSDEVICE=
BUILTMEDIALIBRARYLIBSSIM=
BUILTMEDIALIBRARYLIBSDEVICE=

if [ -z "$MAKEFLAGS" ]; then
    MAKEFLAGS="-j$(sysctl -n machdep.cpu.core_count || nproc)";
fi

set -e

usage()
{
   cat << EOF
   usage: $0

   OPTIONS
    -v      Be more verbose
    -d      Enable debug mode
    -m      Skip medialibrary compilation
    -n      Skip script steps requiring network interaction
    -c      Clean all target build
    -s      Enable medialibrary build for simulators
    -x      Skip medialibrary dependencies build
    -a      Build for specific architecture(all|i386|x86_64|armv7|armv7s|aarch64)
    -p      VLCKit path(default is ~/)
    -k      Build VLCKit
EOF
}

while getopts "hvdmncsxa:p:k" OPTION
do
    case $OPTION in
        h)
            usage
            exit 1
            ;;
        v)
            VERBOSE=yes
            MAKEFLAGS=""
            ;;
        d)
            BUILD_TYPE="Debug"
            ;;
        m)
            SKIP_MEDIALIBRARY=yes
            ;;
        n)
            NO_NETWORK=yes
            ;;
        c)
            CLEAN=yes
            ;;
        s)
            SIMULATOR=yes
            ;;
        x)
            SKIP_DEPENDENCIES=yes
            ;;
        a)
            ARCH=$OPTARG
            ;;
        p)
            VLCKIT_PATH=$OPTARG
            ;;
        k)
            BUILD_VLCKIT=yes
            ;;
        ?)
            usage
            exit 1
            ;;
    esac
done
shift "$((OPTIND-1))"

ROOT_DIR="$(pwd)"
MEDIALIBRARY_DIR="${ROOT_DIR}/medialibrary"
DEPENDENCIES_DIR="${MEDIALIBRARY_DIR}/dependencies"
VLC_DIR=""
VLCKIT_DIR=""
LIBJPEG_DIR="${DEPENDENCIES_DIR}/libjpeg-turbo"
LIBJPEG_BUILD_DIR=""
LIBJPEG_INCLUDE_DIR=""

# Helpers

spushd()
{
    pushd "$1" 2>&1> /dev/null
}

spopd()
{
    popd 2>&1> /dev/null
}


log()
{
    local green="\033[1;32m"
    local orange="\033[1;91m"
    local red="\033[1;31m"
    local normal="\033[0m"
    local color=$green
    local msgType=$1

    if [ "$1" = "warning" ]; then
        color=$orange
        msgType="warning"
    elif [ "$1" = "error" ]; then
        color=$red
        msgType="error"
    fi
    echo "[${color}${msgType}${normal}] $2"
}

getActualArch()
{
    if [ "$1" = "aarch64" ]; then
        echo "arm64"
    else
        echo "$1"
    fi
}

isSimulatorArch() {
    if [ "$1" = "i386" -o "$1" = "x86_64" ];then
        return 0
    else
        return 1
    fi
}

cleanEnvironment()
{
    export AS=""
    export CCAS=""
    export ASCPP=""
    export CC=""
    export CFLAGS=""
    export CPPFLAGS=""
    export CXX=""
    export CXXFLAGS=""
    export CXXCPPFLAGS=""
    export OBJC=""
    export OBJCFLAGS=""
    export LD=""
    export LDFLAGS=""
    export STRIP=""
    export PKG_CONFIG_LIBDIR=""
    export PKG_CONFIG_PATH=""
}

locateVLCKit()
{
    log "info" "Looking for VLCKit..."
    local path=$VLCKIT_PATH

    if [ "$BUILD_VLCKIT" == "yes" ]; then
        log "info" "Cloning VLCKit..."
        git clone https://code.videolan.org/videolan/VLCKit.git
        spushd VLCKit
            git checkout 3.0
            log "info" "Starting VLCKit 3.0 build..."
            # A specific architecture isn't needed, aarch64 was choosen.
            ./buildMobileVLCKit.sh -vfa aarch64
            path="`pwd`"
        spopd # VLCKit
    elif [ "$VLCKIT_PATH" == ~ ]; then
        log "warning" "VLCKit path not provided, will look for it at ~/"

        path="`find ${VLCKIT_PATH} -maxdepth 5 -type d -name 'VLCKit' -print -quit`"
        if [ -z "${path}" ]; then
            log "error" "Unable to find VLCKit!"
            exit 1
        fi
    fi

    VLC_DIR="${path}/libvlc/vlc"
    VLCKIT_DIR="${path}/build"
    log "info" "Found at ${path}"
    log "info" "Setting libvlc directory at ${VLC_DIR}"
}

exportVLC()
{
    local os=$1
    local platform=$2
    local architecture=$3

    export PKG_CONFIG_PATH="${VLC_DIR}/install-${os}${platform}/${architecture}/lib/pkgconfig"
    log "info" "PKG_CONFIG_PATH set to ${PKG_CONFIG_PATH}"

    export PATH="${VLC_DIR}/extras/tools/build/bin:${PATH}"
    log "info" "PATH set to ${PATH}"
}

# Retrieve medialibrary

fetchMedialibrary()
{
    log "info" "Fetching Medialibrary..."
    if [ "$NO_NETWORK" = "no" ]; then
        if [ -d ${MEDIALIBRARY_DIR} ]; then
            spushd ${MEDIALIBRARY_DIR}
                git pull origin master --rebase
                git reset --hard ${TESTED_HASH}
        else
            git clone https://code.videolan.org/videolan/medialibrary.git
            spushd ${MEDIALIBRARY_DIR}
                git checkout -B localBranch ${TESTED_HASH}
        fi
                git submodule update --init
                spushd libvlcpp
                    git am $ROOT_DIR/Resources/patches/*.patch
                spopd #libvlcpp
        spopd #medialibrary
    fi
}

buildLibJpeg()
{
    local arch=$1
    local target=$2
    local platform=$3
    local libjpegRelease="1.5.3"
    local prefix="${LIBJPEG_DIR}/install/${platform}/${arch}"

    if [ ! -d "${LIBJPEG_DIR}" ]; then
        if [ "$NO_NETWORK" = "no" ]; then
            log "warning" "libjpeg source not found! Starting download..."
            git clone https://github.com/libjpeg-turbo/libjpeg-turbo.git
            spushd libjpeg-turbo
                git checkout tags/${libjpegRelease}
            spopd
        fi
    fi
    log "info" "Starting libjpeg configuration..."
    spushd libjpeg-turbo
        if [ ! -d "configure" ]; then
            autoreconf --install
        fi
        if [ ! -d "build" ]; then
            mkdir build
        fi
        spushd build
            if [ ! -d "$platform" ]; then
                mkdir $platform
            fi
            if [ ! -d "$platform/$arch" ]; then
                mkdir $platform/$arch
            fi
            spushd $platform/$arch
                ${LIBJPEG_DIR}/configure \
                               --host=$target \
                               --prefix=$prefix \
                               --disable-shared \
                               CXX=$CXX_COMPILATOR
                log "info" "Starting libjpeg make..."
                make ${MAKEFLAGS}
                if [ ! -d "${prefix}" ]; then
                    mkdir -p $prefix
                fi
                make install
                LIBJPEG_BUILD_DIR="${prefix}/lib/"
                LIBJPEG_INCLUDE_DIR="${prefix}/include/"
                log "info" "libjpeg armed and ready for ${arch}!"
            spopd
        spopd
    spopd
}

buildDependencies()
{
    log "info" "Starting build for medialibrary dependencies..."
    if [ ! -d "${DEPENDENCIES_DIR}" ]; then
        mkdir -p $DEPENDENCIES_DIR
    fi
    spushd $DEPENDENCIES_DIR
        buildLibJpeg $1 $2 $3
    spopd
}

buildMedialibrary()
{
    log "info" "Starting Medialibrary build..."

    local os=$1
    local arch=$2
    local platform=$3
    local makeOptions=""

    spushd ${MEDIALIBRARY_DIR}
        if [ ! -d build ]; then
            mkdir build
        fi
        spushd build
            local actualArch="`getActualArch ${arch}`"
            local currentDir="`pwd`"
            local prefix="${currentDir}/${os}${platform}-install/${actualArch}"
            local buildDir="${currentDir}/${os}${platform}-build/${actualArch}"
            local target="${arch}-apple-darwin16.5.0" #xcode 8.3 clang version
            local optim="-O3 -g"
            local medialibraryFlag="--disable-debug"

            log "info" "Building ${arch} with SDK version ${SDK_VERSION} for platform: ${platform}"

            SDKROOT=`xcode-select -print-path`/Platforms/${os}${platform}.platform/Developer/SDKs/${os}${platform}${SDK_VERSION}.sdk
            if [ ! -d "${SDKROOT}" ]; then
                log "error" "${SDKROOT} does not exist, please install required SDK, or set SDKROOT manually."
                exit 1
            fi

            if [ "$BUILD_TYPE" = "Debug" ]; then
                optim="-O0 -g"
                medialibraryFlag="--enable-debug"
            fi

            CFLAGS="-isysroot ${SDKROOT} -arch ${actualArch} ${optim}"
            LDFLAGS="-isysroot ${SDKROOT} -arch ${actualArch}"

            # there is no thread_local in the C++ i386 runtime
            if [ "$actualArch" = "i386" ]; then
                CFLAGS+=" -D__thread="
            fi

            if [ "$platform" = "Simulator" ]; then
                CFLAGS+=" -${OSVERSIONMINCFLAG}-simulator-version-min=${SDK_MIN}"
                LDFLAGS+=" -Wl,-${OSVERSIONMINLDFLAG}_simulator_version_min,${SDK_MIN}"
            else
                CFLAGS+=" -${OSVERSIONMINCFLAG}-version-min=${SDK_MIN}"
                LDFLAGS+=" -Wl,-${OSVERSIONMINLDFLAG}_version_min,${SDK_MIN}"
            fi

            EXTRA_CFLAGS="${CFLAGS}"
            EXTRA_LDFLAGS="${LDFLAGS}"

            export CFLAGS="${CFLAGS}"
            export CXXFLAGS="${CFLAGS}"
            export CPPFLAGS="${CFLAGS}"
            export LDFLAGS=${LDFLAGS}

            exportVLC ${os} ${platform} ${actualArch}

            if [ "${SKIP_DEPENDENCIES}" != "yes" ]; then
                buildDependencies $actualArch $target $platform
            else
                log "warning" "Build of medialibrary dependencies skipped..."
                LIBJPEG_BUILD_DIR="${LIBJPEG_DIR}/build/${arch}-${platform}"
                LIBJPEG_INCLUDE_DIR="${LIBJPEG_DIR}/install/${platform}/${arch}/include/"
            fi

            if [ "$VERBOSE" = "yes" ]; then
                makeOptions="${makeOptions} V=1"
            else
                makeOptions=${MAKEFLAGS}
            fi

            local currentXcode="/Application/Xcode.app/Contents/Developer/Platforms/${os}${platform}.platform/Developer/SDKs/${os}${platform}.sdk/usr"
            mkdir -p $buildDir && spushd $buildDir

                $MEDIALIBRARY_DIR/bootstrap && \
                $MEDIALIBRARY_DIR/configure \
                                   --disable-shared \
                                   $medialibraryFlag \
                                   --prefix=$prefix \
                                   --host=$target \
                                   CXX=$CXX_COMPILATOR \
                                   OBJCXX=$OBJCXX_COMPILATOR \
                                   LIBJPEG_LIBS="-L${LIBJPEG_BUILD_DIR} -ljpeg" \
                                   LIBJPEG_CFLAGS="-I${LIBJPEG_INCLUDE_DIR}" \
                                   SQLITE_LIBS="-L${currentXcode}/lib/libsqlite3.dylib -lsqlite3" \
                                   SQLITE_CFLAGS="-I${currentXcode}/include"

                log "info" "Starting make in ${buildDir}..."
                make -C $buildDir $makeOptions > ${out}
                make -C $buildDir install > ${out}

            spopd

            if [ $? -ne 0 ]; then
                log "error" "medialibrary build failed!"
                exit 1
            fi
            log "info" "medialibrary armed and ready for ${arch}!"
        spopd #build
    spopd #medialibrary
}

# from buildMobileVLCKit.sh
buildXcodeproj()
{
    local target="$2"
    local platform="$3"

    log "info" "Starting build $1 ($target, ${BUILD_TYPE}, $platform)..."

    local architectures=""
    if [ "$ARCH" == "all" ]; then
        if [ "$platform" = "iphonesimulator" ]; then
            architectures="i386 x86_64 arm64"
        else
            architectures="armv7 armv7s arm64"
        fi
    else
        architectures="`getActualArch $ARCH`"
    fi
    xcodebuild archive \
               -project "$1.xcodeproj" \
               -sdk $platform$SDK \
               -configuration ${BUILD_TYPE} \
               ARCHS="${architectures}" \
               IPHONEOS_DEPLOYMENT_TARGET=${SDK_MIN} \
               -scheme "$target" \
               -archivePath build/"$target"-$platform$SDK.xcarchive \
               SKIP_INSTALL=no \
               > ${out}
}

collectBuiltMedialibraryLibs()
{
    local medialibraryInstallDir="${MEDIALIBRARY_DIR}/build/iPhoneOS-install"
    local medialibrarySimulatorInstallDir="${MEDIALIBRARY_DIR}/build/iPhoneSimulator-install"
    local medialibraryArch="`ls ${medialibraryInstallDir}`"
    local medialibrarySimulatorArch="`ls ${medialibrarySimulatorInstallDir}`"
    local devicefiles=""
    local simulatorfiles=""

    log "info" "Finding libmedialibrary.a binaries..."

    for i in ${medialibraryArch}
    do
        devicefiles="${medialibraryInstallDir}/${i}/lib/libmedialibrary.a ${devicefiles}"
    done

    if [ "$ARCH" = "all" ] || isSimulatorArch $ARCH; then
        for i in ${medialibrarySimulatorArch}
        do
            simulatorfiles="${medialibrarySimulatorInstallDir}/${i}/lib/libmedialibrary.a ${simulatorfiles}"
        done
    fi

    BUILTMEDIALIBRARYLIBSSIM=$simulatorfiles
    BUILTMEDIALIBRARYLIBSDEVICE=$devicefiles

    log "info" "libmedialibrary libs collected!"
}

collectBuiltJPEGLibs()
{
    local libjpegInstallDir="${LIBJPEG_DIR}/install"
    local files=""

    log "info" "Finding libjpeg.a binaries..."

    spushd ${libjpegInstallDir}
    for i in `ls OS`
    do
        files="${libjpegInstallDir}/OS/${i}/lib/libjpeg.a ${files}"
    done
    BUILTJPEGLIBSDEVICE=$files

    files=""
    for i in `ls Simulator`
    do
        files="${libjpegInstallDir}/Simulator/${i}/lib/libjpeg.a ${files}"
    done
    BUILTJPEGLIBSSIM=$files
    spopd

    log "info" "libJPEG libs collected!"
}

createFramework()
{
    local target="$1"
    local libPath=""
    local platform="iphoneos"
    local framework="${target}.xcframework"
    local medialibraryLibDir="${MEDIALIBRARY_DIR}/build"
    local productPath=""
    local frameworks=""

    log "info" "Starting the creation of $framework..."

    productPath=$ROOT_DIR/build/VLCMediaLibraryKit-${platform}.xcarchive
    if [ -d ${productPath} ];then
        dsymfolder=${productPath}/dSYMs/VLCMediaLibraryKit.framework.dSYM
        bcsymbolmapfolder=${productPath}/BCSymbolMaps
        frameworks="$frameworks -framework VLCMediaLibraryKit-${platform}.xcarchive/Products/Library/Frameworks/VLCMediaLibraryKit.framework -debug-symbols $dsymfolder"
        if [ -d ${bcsymbolmapfolder} ];then
            info "Bitcode support found"
            spushd $bcsymbolmapfolder
            for i in `ls *.bcsymbolmap`
            do
                frameworks+=" -debug-symbols $bcsymbolmapfolder/$i"
            done
            spopd
        fi
    fi

    platform="iphonesimulator"
    productPath=$ROOT_DIR/build/VLCMediaLibraryKit-${platform}.xcarchive
    if [ -d ${productPath} ];then
        dsymfolder=${productPath}/dSYMs/VLCMediaLibraryKit.framework.dSYM
        frameworks="$frameworks -framework VLCMediaLibraryKit-${platform}.xcarchive/Products/Library/Frameworks/VLCMediaLibraryKit.framework -debug-symbols $dsymfolder"
    fi

    # Assumes both platforms were built currently
    spushd build
    rm -rf VLCMediaLibraryKit.xcframework
    xcodebuild -create-xcframework $frameworks -output VLCMediaLibraryKit.xcframework
    spopd # build

    log "info" "$framework created!"
}

out="/dev/null"
if [ "$VERBOSE" = "yes" ]; then
    out="/dev/stdout"
fi

##################
# Command Center #
##################

if [ "x$1" != "x" ]; then
    usage
    exit 1
fi

cleanEnvironment

locateVLCKit

if [ "$SKIP_MEDIALIBRARY" != "yes" ]; then
    fetchMedialibrary

    #Mobile first!
    if [ "$ARCH" = "all" ]; then
        buildMedialibrary "iPhone" "i386" "Simulator"
        buildMedialibrary "iPhone" "x86_64" "Simulator"
        buildMedialibrary "iPhone" "aarch64" "Simulator"
        buildMedialibrary "iPhone" "armv7" "OS"
        buildMedialibrary "iPhone" "armv7s" "OS"
        buildMedialibrary "iPhone" "aarch64" "OS"
    else
        platform="OS"

        if isSimulatorArch $ARCH; then
            platform="Simulator"
        fi
        buildMedialibrary "iPhone" "$ARCH" "$platform"
    fi

else
    log "warning" "Build of Medialibrary skipped..."
fi

if [ "$CLEAN" = "yes" ]; then
    xcodebuild -alltargets clean
    log "info" "Xcode build cleaned!"
fi
collectBuiltJPEGLibs
collectBuiltMedialibraryLibs

rm -f $ROOT_DIR/Resources/dependencies.xcconfig
touch $ROOT_DIR/Resources/dependencies.xcconfig
echo "// This file is autogenerated by $(basename $0)" >> $ROOT_DIR/Resources/dependencies.xcconfig
echo "LIBJPEG_LIBRARIES_SIMULATOR=$BUILTJPEGLIBSSIM" >> $ROOT_DIR/Resources/dependencies.xcconfig
echo "MEDIALIBRARY_LIBRARIES_SIMULATOR=$BUILTMEDIALIBRARYLIBSSIM" >> $ROOT_DIR/Resources/dependencies.xcconfig
echo "LIBJPEG_LIBRARIES_DEVICE=$BUILTJPEGLIBSDEVICE" >> $ROOT_DIR/Resources/dependencies.xcconfig
echo "MEDIALIBRARY_LIBRARIES_DEVICE=$BUILTMEDIALIBRARYLIBSDEVICE" >> $ROOT_DIR/Resources/dependencies.xcconfig
echo "MOBILEVLCKIT_XCFRAMEWORK=$VLCKIT_DIR" >> $ROOT_DIR/Resources/dependencies.xcconfig

if [ "$ARCH" = "all" ] || isSimulatorArch $ARCH; then
    buildXcodeproj VLCMediaLibraryKit "VLCMediaLibraryKit" iphonesimulator
fi
if [ "$ARCH" = "all" ] || ! isSimulatorArch $ARCH; then
    buildXcodeproj VLCMediaLibraryKit "VLCMediaLibraryKit" iphoneos
fi

createFramework "VLCMediaLibraryKit"
