#!/bin/sh

CLEAN=no
TESTS=no
VERBOSE=no
ROOT_DIR=default
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
    -c      Clean build
EOF
}

while getopts "hvdtmc" OPTION
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

# info/warning/error colors and parameters;
info()
{
    local green="\033[1;32m"
    local normal="\033[0m"
    echo "[${green}info${normal}] $1"
}

# Retrieve medialibrary
buildMedialibrary()
{
    mkdir -p medialibrary
    pushd medialibrary
        if [ -d medialibrary ]; then
            pushd medialibrary
                git pull --rebase
            popd
        else
            git clone git@code.videolan.org:videolan/medialibrary.git
            pushd medialibrary
                git submodule update --init
                mkdir build
                pushd build
                    ../bootstrap
                    local makeOptions=""
                    local configureOptions="--disable-shared"
                    if [ "$TESTS" = "yes" ]; then
                        configureOptions="${configureOptions} --enable-tests"
                    fi
                    ../configure $configureOptions CXX=$CXX_COMPILATOR OBJCXX=$OBJCXX_COMPILATOR

                    if [ "$VERBOSE" = "yes" ]; then
                        makeOptions="V=1"
                    fi
                    make $makeOptions

                    if [ $? -ne 0 ]; then
                        info "welp it failed but info it still happy"
                    fi
                popd
            popd
         fi
    popd
}

# from buildMobileVLCKit.sh
buildXcodeproj()
{
    local target="$2"
    local platform="$3"

    info "Starting build $1 ($target, ${BUILD_TYPE}, $platform)..."

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
    info "Starting Medialibrary build..."
    buildMedialibrary
else
    info "Build of Medialibrary skipped..."
fi

buildXcodeproj MediaLibraryKit "MediaLibraryKit" iphoneos

if [ "$CLEAN" = "yes" ]; then
    xcodebuild clean
fi

