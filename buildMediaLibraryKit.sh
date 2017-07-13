#!/bin/sh

CLEAN=no
SDK_MIN=9.0
VERBOSE=no
ROOT_DIR=default
SIMULATOR=no
BUILD_TYPE="Release"
SDK_VERSION=`xcrun --sdk iphoneos --show-sdk-version`
CXX_COMPILATOR=clang++
SKIPMEDIALIBRARY=no
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
EOF
}

while getopts "hvdmcs" OPTION
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
            SKIPMEDIALIBRARY=yes
            ;;
        c)
            CLEAN=yes
            ;;
        s)
            SIMULATOR=yes
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

buildMedialibrary()
{
    log "info" "Starting Medialibrary build..."

    local os=$1
    local arch=$2
    local platform=$3
    local makeOptions=""
    local configureOptions="--disable-shared"

    spushd libmedialibrary
        spushd medialibrary
            if [ ! -d build ]; then
                mkdir build
            fi
            spushd build
                local actualArch=$arch

                if [ "${arch}" = "aarch64" ]; then
                    actualArch="arm64"
                fi

                local currentDir="`pwd`"
                local prefix="${currentDir}/${os}${platform}-install/${actualArch}"
                local buildDir="${currentDir}/${os}${platform}-build/${actualArch}"
                local target="${arch}-apple-darwin16.5.0" #xcode 8.3 clang version

                log "warning" "build Directory: $buildDir with prefix: $prefix"
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

                configureOptions="${configureOptions} --prefix=${prefix} --host=${target}"

                if [ "$VERBOSE" = "yes" ]; then
                    makeOptions="${makeOptions} V=1"
                fi

                mkdir -p $buildDir && spushd $buildDir

                    $MEDIALIBRARY_DIR/bootstrap && \
                        $MEDIALIBRARY_DIR/configure $configureOptions CXX=$CXX_COMPILATOR OBJCXX=$OBJCXX_COMPILATOR
                    log "info" "Staring make in ${buildDir}..."
                    make -C $buildDir $makeOptions > ${out}
                    make -C ${buildDir} install > ${out}

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
    local files=""
    local architectures="`ls ${medialibraryInstallDir}`"

    log "info" "Starting the creation of a libmedialibrary.a bundle..."

    for i in ${architectures}
    do
        files="${medialibraryInstallDir}/${i}/lib/libmedialibrary.a ${files}"
    done

    lipo ${files} -create -output "${MEDIALIBRARY_DIR}/build/libmedialibrary.a"

    log "info" "libmedialibrary.a bundle armed and ready to use!"
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
        lipo -create $BUILD_TYPE-$platform/libMediaLibraryKit.a \
            -o $framework/$target && \
        chmod a+x $framework/$target && \
        cp -pr $BUILD_TYPE-$platform/$target $framework/Headers
    spopd

    log "info" "$framework armed and ready to use!"
}

###

out="/dev/null"
if [ "$VERBOSE" = "yes" ]; then
    out="/dev/stdout"
fi

if [ "x$1" != "x" ]; then
    usage
    exit 1
fi

if [ "$SKIPMEDIALIBRARY" != "yes" ]; then
    fetchMedialibrary

    #Mobile first!
    if [ "$SIMULATOR" = "yes" ]; then
        buildMedialibrary "iPhone" "i386" "Simulator"
        buildMedialibrary "iPhone" "x86_64" "Simulator"
    fi
    buildMedialibrary "iPhone" "armv7" "OS"
    buildMedialibrary "iPhone" "armv7s" "OS"
    buildMedialibrary "iPhone" "aarch64" "OS"
else
    log "warning" "Build of Medialibrary skipped..."
fi

if [ "$CLEAN" = "yes" ]; then
    xcodebuild -alltargets clean
    log "info" "Xcode build cleaned!"
fi

if [ "$SIMULATOR" = "yes" ]; then
    lipoMedialibrary iPhoneSimulator
fi

lipoMedialibrary iPhoneOS

buildXcodeproj MediaLibraryKit "MediaLibraryKit" iphoneos
createFramework "MedialibraryKit" iphoneos
