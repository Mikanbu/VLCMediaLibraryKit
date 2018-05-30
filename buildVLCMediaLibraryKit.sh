#!/bin/sh

ARCH="all"
CLEAN=no
SDK_MIN=9.0
VERBOSE=no
ROOT_DIR=default
SIMULATOR=no
BUILD_TYPE="Release"
SDK_VERSION=`xcrun --sdk iphoneos --show-sdk-version`
CXX_COMPILATOR=clang++
SKIP_MEDIALIBRARY=no
SKIP_DEPENDENCIES=no
OBJCXX_COMPILATOR=clang++

set -e

usage()
{
   cat << EOF
   usage: $0

   OPTIONS
    -v      Be more verbose
    -d      Enable debug mode
    -m      Skip medialibrary compilation
    -c      Clean all target build
    -s      Enable medialibrary build for simulators
    -x      Skip medialibrary dependencies build
    -a      Build for specific architecture(all|i386|x86_64|armv7|armv7s|aarch64)
EOF
}

while getopts "hvdmcsxa:" OPTION
do
    case $OPTION in
        h)
            usage
            exit 1
            ;;
        v)
            VERBOSE=yes
            ;;
        d)
            BUILD_TYPE="Debug"
            ;;
        m)
            SKIP_MEDIALIBRARY=yes
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
        ?)
            usage
            exit 1
            ;;
    esac
done
shift "$((OPTIND-1))"

ROOT_DIR="$(pwd)"
MEDIALIBRARY_DIR="${ROOT_DIR}/libmedialibrary/medialibrary"
DEPENDENCIES_DIR="${MEDIALIBRARY_DIR}/dependencies"
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

# Retrieve medialibrary

fetchMedialibrary()
{
    log "info" "Fetching Medialibrary..."
    mkdir -p libmedialibrary
    spushd libmedialibrary
        if [ -d medialibrary ]; then
            spushd medialibrary
                git pull --rebase
        else
            git clone git@code.videolan.org:videolan/medialibrary.git
            spushd medialibrary
        fi
        git submodule update --init
        spopd #medialibrary
    spopd #libmedialibrary
}

buildLibJpeg()
{
    local arch=$1
    local target=$2
    local libjpegRelease="1.5.2"
    LIBJPEG_DIR="${DEPENDENCIES_DIR}/libjpeg-turbo"
    local prefix="${LIBJPEG_DIR}/install/${arch}"

    if [ ! -d "${LIBJPEG_DIR}" ]; then
        log "warning" "libjpeg source not found! Starting download..."
        git clone git@github.com:libjpeg-turbo/libjpeg-turbo.git
        spushd libjpeg-turbo
            git checkout tags/${libjpegRelease}
        spopd
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
            if [ ! -d "$arch" ]; then
                mkdir $arch
            fi
            spushd $arch
                ${LIBJPEG_DIR}/configure \
                               --host=$target \
                               --prefix=$prefix \
                               --disable-shared
                log "info" "Starting libjpeg make..."
                make
                if [ ! -d "${prefix}" ]; then
                    mkdir -p $prefix
                fi
                make install
                LIBJPEG_BUILD_DIR="`pwd`"
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
        buildLibJpeg $1 $2
    spopd
}

buildMedialibrary()
{
    log "info" "Starting Medialibrary build..."

    local os=$1
    local arch=$2
    local platform=$3
    local makeOptions=""

    spushd libmedialibrary
        spushd medialibrary
            if [ ! -d build ]; then
                mkdir build
            fi
            spushd build
                local actualArch="`getActualArch ${arch}`"
                local currentDir="`pwd`"
                local prefix="${currentDir}/${os}${platform}-install/${actualArch}"
                local buildDir="${currentDir}/${os}${platform}-build/${actualArch}"
                local target="${arch}-apple-darwin16.5.0" #xcode 8.3 clang version

                log "info" "Building ${arch} with SDK version ${SDK_VERSION} for platform: ${platform}"

                SDKROOT=`xcode-select -print-path`/Platforms/${os}${platform}.platform/Developer/SDKs/${os}${platform}${SDK_VERSION}.sdk
                if [ ! -d "${SDKROOT}" ]; then
                    log "error" "${SDKROOT} does not exist, please install required SDK, or set SDKROOT manually."
                    exit 1
                fi

                CFLAGS="-isysroot ${SDKROOT} -arch ${actualArch}"
                export CFLAGS="${CFLAGS}"
                export CXXFLAGS="${CFLAGS}"
                export CPPFLAGS="${CFLAGS}"

                if [ "${SKIP_DEPENDENCIES}" != "yes" ]; then
                    buildDependencies $actualArch $target
                else
                    log "warning" "Build of medialibrary dependencies skipped..."
                    LIBJPEG_BUILD_DIR="${LIBJPEG_DIR}/build/${arch}"
                    LIBJPEG_INCLUDE_DIR="${LIBJPEG_DIR}/install/${arch}/include/"
                fi

                if [ "$VERBOSE" = "yes" ]; then
                    makeOptions="${makeOptions} V=1"
                fi

                mkdir -p $buildDir && spushd $buildDir

                    $MEDIALIBRARY_DIR/bootstrap && \
                    $MEDIALIBRARY_DIR/configure \
                                       --disable-shared \
                                       --prefix=$prefix \
                                       --host=$target \
                                       CXX=$CXX_COMPILATOR \
                                       OBJCXX=$OBJCXX_COMPILATOR \
                                       LIBJPEG_LIBS="-L${LIBJPEG_BUILD_DIR} -ljpeg" \
                                       LIBJPEG_CFLAGS="-I${LIBJPEG_INCLUDE_DIR}"

                    log "info" "Starting make in ${buildDir}..."
                    make -C $buildDir $makeOptions > ${out}
                    make -C $buildDir install > ${out}

                spopd

                if [ $? -ne 0 ]; then
                    log "error" "medialibrary build failed!"
                fi
            spopd #build
        spopd #medialibrary
    spopd #libmedialibrary
}

# from buildMobileVLCKit.sh
buildXcodeproj()
{
    local target="$2"
    local platform="$3"

    log "info" "Starting build $1 ($target, ${BUILD_TYPE}, $platform)..."

    local architectures=""
    if [ "$ARCH" == "all" ]; then
        if [ "$TVOS" != "yes" ]; then
            if [ "$platform" = "iphonesimulator" ]; then
                architectures="i386 x86_64"
            else
                architectures="armv7 armv7s arm64"
            fi
        else
            if [ "$platform" = "appletvsimulator" ]; then
                architectures="x86_64"
            else
                architectures="arm64"
            fi
        fi
    else
        architectures="`getActualArch $ARCH`"
    fi
    xcodebuild -project "$1.xcodeproj" \
               -target "$target" \
               -sdk $platform$SDK \
               -configuration ${BUILD_TYPE} \
               ARCHS="${architectures}" \
               IPHONEOS_DEPLOYMENT_TARGET=${SDK_MIN} \
               > ${out}
}

lipoMedialibrary()
{
    local medialibraryInstallDir="${MEDIALIBRARY_DIR}/build/${1}-install"
    local medialibraryArch="`ls ${medialibraryInstallDir}`"
    local files=""
    local darwinFiles=""

    log "info" "Starting the creation of a libmedialibrary.a bundle..."
    for i in ${medialibraryArch}
    do
        files="${medialibraryInstallDir}/${i}/lib/libmedialibrary.a ${files}"
        darwinFiles="${medialibraryInstallDir}/${i}/lib/libmedialibrary_macos.a ${darwinFiles}"
    done

    lipo ${files} -create -output "${MEDIALIBRARY_DIR}/build/libmedialibrary.a"
    lipo ${darwinFiles} -create -output "${MEDIALIBRARY_DIR}/build/libmedialibrary_macos.a"
    log "info" "libmedialibrary.a bundle armed and ready to use!"
    log "info" "libmedialibrary_macos.a bundle armed and ready to use!"
}

lipoJpeg()
{
    local libjpegInstallDir="${LIBJPEG_DIR}/install"
    local libjpegArch="`ls ${libjpegInstallDir}`"
    local files=""

    log "info" "Starting the creation of a libjpeg.a bundle..."

    for i in ${libjpegArch}
    do
        files="${libjpegInstallDir}/${i}/lib/libjpeg.a ${files}"
    done

    lipo ${files} -create -output "${MEDIALIBRARY_DIR}/build/libjpeg.a"
    log "info" "libjpeg.a bundle armed and ready to use!"
}

createFramework()
{
    local target="$1"
    local platform="$2"
    local framework="${target}.framework"
    local medialibraryLibDir="${MEDIALIBRARY_DIR}/build"

    log "info" "Starting the creation of $framework ($target, $platform)..."

    if [ ! -d build ]; then
        mkdir build
    fi
    spushd build
        rm -rf $framework && \
        mkdir $framework && \
        lipo -create $BUILD_TYPE-$platform/libVLCMediaLibraryKit.a \
            -o $framework/$target && \
        chmod a+x $framework/$target && \
        cp -pr $BUILD_TYPE-$platform/$target $framework/Headers
    spopd

    log "info" "$framework armed and ready to use!"
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

if [ "$SKIP_MEDIALIBRARY" != "yes" ]; then
    fetchMedialibrary

    #Mobile first!
    if [ "$ARCH" = "all" ]; then
        if [ "$SIMULATOR" = "yes" ]; then
            buildMedialibrary "iPhone" "i386" "Simulator"
            buildMedialibrary "iPhone" "x86_64" "Simulator"
        fi
        buildMedialibrary "iPhone" "armv7" "OS"
        buildMedialibrary "iPhone" "armv7s" "OS"
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

if [ "$ARCH" = "all" ] || isSimulatorArch $ARCH; then
        lipoMedialibrary iPhoneSimulator
        buildXcodeproj VLCMediaLibraryKit "VLCMediaLibraryKit" iphonesimulator
        createFramework "VLCMediaLibraryKit" iphonesimulator
fi
if [ "$ARCH" = "all" ] || ! isSimulatorArch $ARCH; then
    lipoMedialibrary iPhoneOS
    buildXcodeproj VLCMediaLibraryKit "VLCMediaLibraryKit" iphoneos
    createFramework "VLCMediaLibraryKit" iphoneos
fi

