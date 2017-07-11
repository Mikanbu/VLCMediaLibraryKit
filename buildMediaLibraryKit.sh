#!/bin/sh

CLEAN=no
TESTS=no
VERBOSE=no
ROOT_DIR=default
SIMULATOR=no
BUILD_TYPE="Release"
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
    -t      Enable tests
    -m      Skip medialibrary compilation
    -c      Clean all target build
    -s      Enable medialibrary build for simulators
EOF
}

while getopts "hvdtmcs" OPTION
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
        t)
            TESTS=yes
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
MEDIALIBRARY_DIR=""

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
buildMedialibrary()
{
    mkdir -p medialibrary
    spushd medialibrary
        if [ -d medialibrary ]; then
            spushd medialibrary
                git pull --rebase
            spopd
        else
            git clone git@code.videolan.org:videolan/medialibrary.git
            spushd medialibrary
                git submodule update --init
                mkdir build
                spushd build
                    local makeOptions=""
                    local configureOptions="--disable-shared"

                    if [ "$TESTS" = "yes" ]; then
                        configureOptions="${configureOptions} --enable-tests"
                    fi
                    if [ "$VERBOSE" = "yes" ]; then
                        makeOptions="V=1"
                    fi

                    ../bootstrap && \
                    ../configure $configureOptions CXX=$CXX_COMPILATOR OBJCXX=$OBJCXX_COMPILATOR && \
                    make $makeOptions

                    if [ $? -ne 0 ]; then
                        log "error" "medialibrary build failed!"
                    fi
                spopd
            spopd
         fi
    spopd
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

    local defs="$GCC_PREPROCESSOR_DEFINITIONS"
    if [ "$SCARY" = "no" ]; then
        defs="$defs NOSCARYCODECS"
    fi
    xcodebuild -project "$1.xcodeproj" \
               -target "$target" \
               -sdk $platform$SDK \
               -configuration ${BUILD_TYPE} \
               ARCHS="${architectures}" \
               IPHONEOS_DEPLOYMENT_TARGET=${SDK_MIN} \
               GCC_PREPROCESSOR_DEFINITIONS="$defs" \
               > ${out}
}

createFramework()
{
    local target="$1"
    local platform="$2"
    local framework="${target}.framework"

    log "info" "Starting the creation of $framework ($target, $platform)..."

    if [ ! -d build ]; then
        mkdir build
    fi
    spushd build
        rm -rf $framework && \
        mkdir $framework && \
        lipo -create $BUILD_TYPE-$platform/libMediaLibraryKit.a \
                     $MEDIALIBRARY_DIR/libmedialibrary.a        \
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
    log "info" "Starting Medialibrary build..."
    buildMedialibrary
else
    log "warning" "Build of Medialibrary skipped..."
fi

MEDIALIBRARY_DIR="${ROOT_DIR}/medialibrary/medialibrary/build/.libs"

if [ "$CLEAN" = "yes" ]; then
    xcodebuild -alltargets clean
    log "info" "Xcode build cleaned!"
fi

buildXcodeproj MediaLibraryKit "MediaLibraryKit" iphoneos
createFramework "MedialibraryKit" iphoneos
