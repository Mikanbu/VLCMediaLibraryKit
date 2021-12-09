#!/bin/sh

ARCH="all"
CLEAN=no
SDK_MIN=9.0
PLATFORM_NAME="iPhone"
PLATFORM_NAME_LOWERCASE="iphone"
VERBOSE=no
ROOT_DIR=default
SIMULATOR=no
NO_NETWORK=no
SKIP_LIBVLC_TOOLS=no
VLCKIT_BASEURL="https://download.videolan.org/cocoapods/prod/"
VLCKIT_NAME="MobileVLCKit"
VLCKIT_RELEASE="3.3.18b6-24e52c1c-9bc28dab"
VLCKIT_SHASUM256_IOS="590baf022ec4c8c23da0cd5557528642711cc056b368f8b48d7247c351fc8927"
VLCKIT_SHASUM256_TVOS="0bd40b4c1bc86b7e50e175afca8ee0660fa94fb870468836d49d450c9a27fc05"
BUILD_TYPE="Release"
TESTED_HASH="5db47475"
CUSTOM_VLCKIT_PATH=~
SDK_VERSION=`xcrun --sdk iphoneos --show-sdk-version`
CXX_COMPILATOR=clang++
SKIP_MEDIALIBRARY=no
SKIP_DEPENDENCIES=no
COMPILE_FOR_TVOS=no
OBJCXX_COMPILATOR=clang++
BITCODE=no
OSVERSIONMINCFLAG=mios
OSVERSIONMINLDFLAG=ios
BUILTJPEGLIBSSIM=
BUILTJPEGLIBSDEVICE=
BUILTSQLITELIBSSIM=
BUILTSQLITELIBSDEVICE=
BUILTMEDIALIBRARYLIBSSIM=
BUILTMEDIALIBRARYLIBSDEVICE=
PKG_CONFIG_PATH=
CREATE_XCFRAMEWORK=no

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
    -p      Path to VLCKit xcframework binary (name of the framework not included in the path)
    -l      Skip libvlc tools compilation (not recommended)
    -t      Compile for tvOS
    -f      Create xcframework
EOF
}

while getopts "hvfdlmncstxa:p:" OPTION
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
            CUSTOM_VLCKIT_PATH=$OPTARG
            ;;
        l)
            SKIP_LIBVLC_TOOLS=yes
            ;;
        t)
            COMPILE_FOR_TVOS=yes
            OSVERSIONMINCFLAG=mtvos
            OSVERSIONMINLDFLAG=tvos
            SDK_VERSION=`xcrun --sdk appletvos --show-sdk-version`
            SDK_MIN=10.2
            BITCODE=yes
            VLCKIT_NAME="TVVLCKit"
            PLATFORM_NAME="AppleTV"
            PLATFORM_NAME_LOWERCASE="appletv"
            VLCKIT_RELEASE="3.3.18b6-24e52c1-9bc28dab" # remove this for future VLCKit releases that are correctly named
            ;;
        f)
            CREATE_XCFRAMEWORK=yes
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

SQLITE_RELEASE="sqlite-autoconf-3340100"
SQLITE_SHA1="c20286e11fe5c2e3712ce74890e1692417de6890"
SQLITE_DIR="${DEPENDENCIES_DIR}/${SQLITE_RELEASE}"
SQLITE_INCLUDE_DIR=""
SQLITE_BUILD_DIR=""

VLCKIT_DIR="${DEPENDENCIES_DIR}/${VLCKIT_NAME}"
LIBVLC_TOOLS_DIR="${DEPENDENCIES_DIR}/LibVLCTools"
VLCKIT_PKGCONFIG_DIR="${VLCKIT_DIR}/pkgconfig"

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

    if [ "$msgType" = "warning" ]; then
        color=$orange
        msgType="warning"
    elif [ "$msgType" = "error" ]; then
        color=$red
        msgType="error"
    fi
    echo "[${color}${msgType}${normal}] $2"
}

getActualArch()
{
    local architecture=$1
    if [ "$architecture" = "aarch64" ]; then
        echo "arm64"
    else
        echo "$architecture"
    fi
}

isSimulatorArch() {
    local architecture=$1
    if [ "$architecture" = "i386" -o "$architecture" = "x86_64" ];then
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
    local path=$CUSTOM_VLCKIT_PATH

    if [ "$CUSTOM_VLCKIT_PATH" == ~ ]; then
        log "error" "VLCKit path not provided but requested"
        exit 1
    fi

    VLC_DIR=""
    VLCKIT_DIR="${path}"
    log "info" "Using custom VLCKit at ${path}"
}

exportPKG()
{
    local os=$1
    local platform=$2
    local architecture=$3

    PKG_CONFIG_PATH="${VLCKIT_PKGCONFIG_DIR}/${architecture}-${platform}:"
    PKG_CONFIG_PATH+="${LIBJPEG_BUILD_DIR}/pkgconfig:"
    PKG_CONFIG_PATH+="${SQLITE_BUILD_DIR}/${os}${platform}/${architecture}"

    export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}"
    log "info" "PKG_CONFIG_PATH set to ${PKG_CONFIG_PATH}"
}

getCPUFamily() {
    local cpuname=$1
    if [ "$cpuname" = "i386" ]; then
        echo "x86"
    else
        echo "$cpuname"
    fi
}

generateCrossFile()
{
    local os=$1
    local platform=$2
    local architecture=$3
    local crossfilesDir="${ROOT_DIR}/buildsystem/crossfiles"
    local crossfileName="$architecture-$platform.crossfile"

    mkdir -p "$crossfilesDir" && spushd "$crossfilesDir"
        if [ -f "$crossfileName" ]; then
            log "warning" "$crossfileName already exists, skipping generation..."
            spopd #crossfilesDir
            return
        fi

        local extraThreadFlags=""
        if [ "$architecture" = "i386" ]; then
            extraThreadFlags=" + ['-Dthread_local=']"
        fi

        touch "$crossfileName"

        echo "# This file is autogenerated by $(basename $0)\n" >> "$crossfileName"

        echo "[constants]" >> "$crossfileName"
        echo "common_flags = ['-arch', '$architecture', '-m${PLATFORM_NAME_LOWERCASE}os-version-min=${SDK_MIN}', '-isysroot', '${SDKROOT}']\n" >> "$crossfileName"

        echo "[binaries]" >> "$crossfileName"
        echo "c = 'clang'" >> "$crossfileName"
        echo "cpp = 'clang++'" >> "$crossfileName"
        echo "objc = 'clang'" >> "$crossfileName"
        echo "objcpp = 'clang++'" >> "$crossfileName"
        echo "ar = 'ar'" >> "$crossfileName"
        echo "strip = 'strip'" >> "$crossfileName"
        echo "pkgconfig = 'pkg-config'\n" >> "$crossfileName"

        echo "[built-in options]" >> "$crossfileName"
        echo "c_args = common_flags${extraThreadFlags}" >> "$crossfileName"
        echo "c_link_args = common_flags" >> "$crossfileName"
        echo "cpp_args = common_flags${extraThreadFlags}" >> "$crossfileName"
        echo "cpp_link_args = common_flags" >> "$crossfileName"
        echo "objc_args = common_flags${extraThreadFlags}" >> "$crossfileName"
        echo "objc_link_args = common_flags" >> "$crossfileName"
        echo "objcpp_args = common_flags${extraThreadFlags}" >> "$crossfileName"
        echo "objcpp_link_args = common_flags\n" >> "$crossfileName"

        echo "[host_machine]" >> "$crossfileName"
        echo "system = 'darwin'" >> "$crossfileName"
        echo "cpu_family = '`getCPUFamily $architecture`'" >> "$crossfileName"
        echo "endian = 'little'" >> "$crossfileName"
        echo "cpu = '$architecture'" >> "$crossfileName"
    spopd #crossfilesDir
}

generateVLCKitPkgConfigFile()
{
    local arch=$1
    local platform=$2

    log "info" "Creating pkgconfig for $arch/$platform..."

    mkdir -p "$VLCKIT_PKGCONFIG_DIR" && spushd "$VLCKIT_PKGCONFIG_DIR"
    mkdir -p "$arch-$platform" && spushd "$arch-$platform"

    if [ "$COMPILE_FOR_TVOS" = "no" ]; then
        if [ "$platform" = "Simulator" ]; then
            local PCPREFIX="${VLCKIT_DIR}/MobileVLCKit.xcframework/ios-arm64_i386_x86_64-simulator/MobileVLCKit.framework"
        else
            local PCPREFIX="${VLCKIT_DIR}/MobileVLCKit.xcframework/ios-arm64_armv7_armv7s/MobileVLCKit.framework"
        fi
    else
        if [ "$platform" = "Simulator" ]; then
            local PCPREFIX="${VLCKIT_DIR}/TVVLCKit.xcframework/tvos-arm64_x86_64-simulator/TVVLCKit.framework"
        else
            local PCPREFIX="${VLCKIT_DIR}/TVVLCKit.xcframework/tvos-arm64/TVVLCKit.framework"
        fi
    fi

    rm -f libvlc.pc
    touch libvlc.pc
    echo "prefix=$PCPREFIX" >> libvlc.pc
    echo "exec_prefix=\${prefix}" >> libvlc.pc
    echo "libdir=\${exec_prefix}" >> libvlc.pc
    echo "includedir=\${prefix}/Headers" >> libvlc.pc
    echo "" >> libvlc.pc
    echo "Name: ${VLCKIT_NAME} libvlc" >> libvlc.pc
    echo "Description: VLC media player external control library through ${VLCKIT_NAME}" >> libvlc.pc
    echo "Version: 3.0.18" >> libvlc.pc
    echo "Cflags: -I\${includedir}" >> libvlc.pc
    echo "Libs: -L\${libdir} -lvlc" >> libvlc.pc
    echo "Libs.private: -lvlccore" >> libvlc.pc

    spopd # $architecture-$platform
    spopd # $VLCKIT_PKGCONFIG_DIR
}

fetchPrebuiltVLCKit()
{
    local actualArch=$1
    local platform=$2

    if [ ! -d "${VLCKIT_DIR}" ]; then
        mkdir -p "$VLCKIT_DIR" && spushd "$VLCKIT_DIR"

        log "info" "Downloading prebuilt VLCKit from ${VLCKIT_BASEURL}${VLCKIT_NAME}-${VLCKIT_RELEASE}.tar.xz"
        curl -O ${VLCKIT_BASEURL}${VLCKIT_NAME}-${VLCKIT_RELEASE}.tar.xz

        local vlckitshasum=""
        if [ "$COMPILE_FOR_TVOS" = "no" ]; then
            vlckitshasum=$VLCKIT_SHASUM256_IOS
        else
            vlckitshasum=$VLCKIT_SHASUM256_TVOS
        fi

        if [ ! "`shasum -a 256 ${VLCKIT_NAME}-${VLCKIT_RELEASE}.tar.xz`" = "${vlckitshasum}  ${VLCKIT_NAME}-${VLCKIT_RELEASE}.tar.xz" ]; then
            log "error" "Wrong sha256 for ${VLCKIT_NAME}-${VLCKIT_RELEASE}.tar.xz"
            log "error" "Expected ${vlckitshasum}, received `shasum -a 256 ${VLCKIT_NAME}-${VLCKIT_RELEASE}.tar.xz`"
            exit 1
        fi

        tar -xozf ${VLCKIT_NAME}-${VLCKIT_RELEASE}.tar.xz
        rm -f ${VLCKIT_NAME}-${VLCKIT_RELEASE}.tar.xz
        mv ${VLCKIT_NAME}-binary/${VLCKIT_NAME}.xcframework ${VLCKIT_NAME}.xcframework
        rm -rf ${VLCKIT_NAME}-binary
        spopd # VLCKIT_DIR
    fi

    if [ "$SKIP_LIBVLC_TOOLS" = "no" ]; then
        if [ ! -d "${LIBVLC_TOOLS_DIR}" ]; then
            mkdir -p "$LIBVLC_TOOLS_DIR" && spushd "$LIBVLC_TOOLS_DIR"
            git init
            git remote add -f origin https://code.videolan.org/videolan/vlc.git
            git config core.sparseCheckout true
            echo "extras/tools/" >> .git/info/sparse-checkout
            git pull origin 3.0.x
    
            spushd ${LIBVLC_TOOLS_DIR}/extras/tools
            ./bootstrap && make
            spopd # ${LIBVLC_TOOLS_DIR}/extras/tools
            spopd # LIBVLC_TOOLS_DIR
        fi
    fi

    generateVLCKitPkgConfigFile $actualArch $platform
}

# Retrieve medialibrary

fetchMedialibrary()
{
    log "info" "Fetching Medialibrary..."
    if [ "$NO_NETWORK" = "no" ]; then
        if [ -d ${MEDIALIBRARY_DIR} ]; then
            spushd ${MEDIALIBRARY_DIR}
                git fetch --all
                git reset --hard ${TESTED_HASH}
        else
            git clone https://code.videolan.org/videolan/medialibrary.git --branch 0.10.x --single-branch medialibrary
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
    local platform=${PLATFORM_NAME}$3
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

buildSqlite()
{
    local arch=$1
    local target=$2
    local prefix="${SQLITE_DIR}/build/${PLATFORM_NAME_LOWERCASE}${arch}/install-dir"

    if [ ! -d "${SQLITE_DIR}" ]; then
        if [ "$NO_NETWORK" = "no" ]; then
            log "warning" "sqlite source not found! Starting download..."
            curl -O https://download.videolan.org/pub/contrib/sqlite/${SQLITE_RELEASE}.tar.gz

            if [ ! "`shasum ${SQLITE_RELEASE}.tar.gz`" = "${SQLITE_SHA1}  ${SQLITE_RELEASE}.tar.gz" ]; then
                log "error" "Wrong sha1 for ${SQLITE_RELEASE}.tar.gz"
                exit 1
            fi

            tar -xozf ${SQLITE_RELEASE}.tar.gz
            rm -f ${SQLITE_RELEASE}.tar.gz
        fi
    fi
    log "info" "Starting sqlite configuration..."
    spushd ${SQLITE_RELEASE}
        if [ ! -e "configure" ]; then
            log "warning" "Found configure file, launching autoreconf..."
            autoreconf --install
        fi
        if [ ! -d "build" ]; then
            mkdir build
        fi
        spushd build
            if [ ! -d "${PLATFORM_NAME}$platform" ]; then
                mkdir ${PLATFORM_NAME}$platform
            fi
            if [ ! -d "${PLATFORM_NAME}$platform/$arch" ]; then
                mkdir ${PLATFORM_NAME}$platform/$arch
            fi
            spushd ${PLATFORM_NAME}$platform/$arch
                ${SQLITE_DIR}/configure \
                               --host=$target \
                               --disable-shared \
                               --disable-readline \
                               CXX=$CXX_COMPILATOR
                log "info" "Starting sqlite make..."
                make ${MAKEFLAGS} libsqlite3.la
                SQLITE_BUILD_DIR="${SQLITE_DIR}/build/"
                SQLITE_INCLUDE_DIR="${SQLITE_DIR}"
                log "info" "sqlite armed and ready for ${arch}!"
            spopd # $arch
        spopd # build
     spopd # $SQLITE_RELEASE
}

buildDependencies()
{
    local actualArch=$1
    local target=$2
    local platform=$3

    log "info" "Starting build for medialibrary dependencies..."
    spushd $DEPENDENCIES_DIR
        buildLibJpeg $actualArch $target $platform
        buildSqlite $actualArch $target $platform
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
            local medialibraryOptimization="3"
            local medialibraryNDebug="true"

            log "info" "Building ${arch} with SDK version ${SDK_VERSION} for platform: ${PLATFORM_NAME}${platform}"

            if [ ! -d "${DEPENDENCIES_DIR}" ]; then
                mkdir -p $DEPENDENCIES_DIR
            fi
            fetchPrebuiltVLCKit $actualArch $platform

            SDKROOT=`xcode-select -print-path`/Platforms/${os}${platform}.platform/Developer/SDKs/${os}${platform}${SDK_VERSION}.sdk
            if [ ! -d "${SDKROOT}" ]; then
                log "error" "${SDKROOT} does not exist, please install required SDK, or set SDKROOT manually."
                exit 1
            fi

            if [ "$BUILD_TYPE" = "Debug" ]; then
                medialibraryOptimization="0"
                medialibraryNDebug="false"
            fi

            CFLAGS="-isysroot ${SDKROOT} -arch ${actualArch}"
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

            if [ "$BITCODE" = "yes" ]; then
                CFLAGS+=" -fembed-bitcode"
            fi

            EXTRA_CFLAGS="${CFLAGS}"
            EXTRA_LDFLAGS="${LDFLAGS}"

            export CFLAGS="${CFLAGS}"
            export CXXFLAGS="${CFLAGS}"
            export CPPFLAGS="${CFLAGS}"
            export LDFLAGS=${LDFLAGS}

            if [ "$SKIP_LIBVLC_TOOLS" = "no" ]; then
                export PATH="${LIBVLC_TOOLS_DIR}/extras/tools/build/bin:${PATH}"
            else
                export PATH="${PATH}"
            fi
            log "info" "PATH set to ${PATH}"

            if [ "${SKIP_DEPENDENCIES}" != "yes" ]; then
                buildDependencies $actualArch $target $platform
            else
                log "warning" "Build of medialibrary dependencies skipped..."
                LIBJPEG_BUILD_DIR="${LIBJPEG_DIR}/build/${arch}-${platform}"
                LIBJPEG_INCLUDE_DIR="${LIBJPEG_DIR}/install/${platform}/${arch}/include/"
                SQLITE_BUILD_DIR="${SQLITE_DIR}/build/"
                SQLITE_INCLUDE_DIR="${SQLITE_DIR}"
            fi

            if [ "$VERBOSE" = "yes" ]; then
                makeOptions="${makeOptions} V=1"
            else
                makeOptions=${MAKEFLAGS}
            fi

            exportPKG ${os} ${platform} ${actualArch}

            generateCrossFile ${os} ${platform} ${actualArch}

            local currentXcode="/Application/Xcode.app/Contents/Developer/Platforms/${os}${platform}.platform/Developer/SDKs/${os}${platform}.sdk/usr"
            mkdir -p $buildDir
        spopd #build

        if [ ! -d "${buildDir}" -o ! -f "${buildDir}/build.ninja" ]; then
            meson \
                -Ddebug=true \
                -Doptimization="${medialibraryOptimization}" \
                -Db_ndebug="${medialibraryNDebug}" \
                --cross-file "${ROOT_DIR}/buildsystem/crossfiles/$actualArch-$platform.crossfile" \
                --prefix "${prefix}" \
                -Ddefault_library=static \
                -Dtests=disabled \
                -Dforce_attachment_api=true \
                $buildDir
        fi
        spushd $buildDir
            ninja
            ninja install
            if [ $? -ne 0 ]; then
                log "error" "medialibrary build failed!"
                exit 1
            fi
            log "info" "medialibrary armed and ready for ${arch}!"
        spopd #$buildDir
    spopd #medialibrary
}

# from buildMobileVLCKit.sh
buildXcodeproj()
{
    local xcproject="$1"
    local target="$2"
    local platform="$3"

    log "info" "Starting build $xcproject ($target, ${BUILD_TYPE}, $platform)..."

    local architectures=""
    if [ "$ARCH" == "all" ]; then
        if [ "$COMPILE_FOR_TVOS" = "no" ]; then
            if [ "$platform" = "iphonesimulator" ]; then
                architectures="i386 x86_64 arm64"
            else
                architectures="armv7 armv7s arm64"
            fi
        else
            if [ "$platform" = "appletvsimulator" ]; then
                architectures="x86_64 arm64"
            else
                architectures="arm64"
            fi
        fi
    else
        architectures="`getActualArch $ARCH`"
    fi

    local bitcodeflag=""
    if [ "$BITCODE" = "yes" ]; then
        bitcodeflag="BITCODE_GENERATION_MODE=bitcode ENABLE_BITCODE=yes"
    fi

    xcodebuild archive \
               -project $xcproject.xcodeproj \
               -sdk $platform$SDK \
               -configuration ${BUILD_TYPE} \
               ARCHS="${architectures}" \
               IPHONEOS_DEPLOYMENT_TARGET=${SDK_MIN} \
               ${bitcodeflag} \
               -scheme "$target" \
               -archivePath build/"$target"-$platform$SDK.xcarchive \
               SKIP_INSTALL=no \
               > ${out}
}

collectBuiltMedialibraryLibs()
{
    local medialibraryInstallDir="${MEDIALIBRARY_DIR}/build/${PLATFORM_NAME}OS-install"
    local medialibrarySimulatorInstallDir="${MEDIALIBRARY_DIR}/build/${PLATFORM_NAME}Simulator-install"
    local medialibraryArch="`ls ${medialibraryInstallDir}`"
    local medialibrarySimulatorArch="`ls ${medialibrarySimulatorInstallDir}`"
    local devicefiles=""
    local simulatorfiles=""

    log "info" "Finding libmedialibrary.a binaries..."

    if [ "$ARCH" = "all" ]; then
        for i in ${medialibraryArch}
        do
            devicefiles="${medialibraryInstallDir}/${i}/lib/libmedialibrary.a ${devicefiles}"
        done

        for i in ${medialibrarySimulatorArch}
        do
            simulatorfiles="${medialibrarySimulatorInstallDir}/${i}/lib/libmedialibrary.a ${simulatorfiles}"
        done
    else
        local actualArch="`getActualArch ${ARCH}`"
        devicefiles="${medialibraryInstallDir}/${actualArch}/lib/libmedialibrary.a"
        simulatorfiles="${medialibrarySimulatorInstallDir}/${actualArch}/lib/libmedialibrary.a"
    fi

    BUILTMEDIALIBRARYLIBSDEVICE=$devicefiles
    BUILTMEDIALIBRARYLIBSSIM=$simulatorfiles

    log "info" "libmedialibrary libs collected!"
}

collectBuiltJPEGLibs()
{
    local libjpegInstallDir="${LIBJPEG_DIR}/install"
    local files=""

    log "info" "Finding libjpeg.a binaries..."

    spushd ${libjpegInstallDir}
        if [ "$ARCH" = "all" ]; then
            for i in `ls ${PLATFORM_NAME_LOWERCASE}OS`
            do
                files="${libjpegInstallDir}/${PLATFORM_NAME_LOWERCASE}OS/${i}/lib/libjpeg.a ${files}"
            done
            BUILTJPEGLIBSDEVICE=$files

            files=""
            for i in `ls ${PLATFORM_NAME_LOWERCASE}Simulator`
            do
                files="${libjpegInstallDir}/${PLATFORM_NAME_LOWERCASE}Simulator/${i}/lib/libjpeg.a ${files}"
            done
            BUILTJPEGLIBSSIM=$files
        else
            local actualArch="`getActualArch ${ARCH}`"
            BUILTJPEGLIBSDEVICE="${libjpegInstallDir}/${PLATFORM_NAME_LOWERCASE}OS/${actualArch}/lib/libjpeg.a"
            BUILTJPEGLIBSSIM="${libjpegInstallDir}/${PLATFORM_NAME_LOWERCASE}Simulator/${actualArch}/lib/libjpeg.a"
        fi
    spopd

    log "info" "libJPEG libs collected!"
}

collectBuiltSQliteLibs()
{
    local sqliteInstallDir="${SQLITE_DIR}/build"
    local sqliteArchDevice="`ls ${sqliteInstallDir}/${PLATFORM_NAME}OS`"
    local sqliteArchSimulator="`ls ${sqliteInstallDir}/${PLATFORM_NAME}Simulator`"
    local deviceFiles=""
    local simulatorFiles=""

    log "info" "Finding libsqlite3.a binaries..."

    if [ "$ARCH" = "all" ]; then
        for i in ${sqliteArchDevice}
        do
            deviceFiles="${sqliteInstallDir}/${PLATFORM_NAME}OS/${i}/.libs/libsqlite3.a ${deviceFiles}"
        done
        BUILTSQLITELIBSDEVICE=$deviceFiles

        for i in ${sqliteArchSimulator}
        do
            simulatorFiles="${sqliteInstallDir}/${PLATFORM_NAME}Simulator/${i}/.libs/libsqlite3.a ${simulatorFiles}"
        done
        BUILTSQLITELIBSSIM=$simulatorFiles
    else
        local actualArch="`getActualArch ${ARCH}`"
        BUILTSQLITELIBSDEVICE="${sqliteInstallDir}/${PLATFORM_NAME}OS/${actualArch}/.libs/libsqlite3.a"
        BUILTSQLITELIBSSIM="${sqliteInstallDir}/${PLATFORM_NAME}Simulator/${actualArch}/.libs/libsqlite3.a"
    fi

    log "info" "libsqlite3.a libs collected!"
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

    platform="appletvos"
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

    platform="appletvsimulator"
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

if [ "$CUSTOM_VLCKIT_PATH" != ~ ]; then
    locateVLCKit
fi

if [ "$SKIP_MEDIALIBRARY" != "yes" ]; then
    fetchMedialibrary

    #Mobile first!
    if [ "$ARCH" = "all" ]; then
        if [ "$COMPILE_FOR_TVOS" = "yes" ]; then
            buildMedialibrary "$PLATFORM_NAME" "x86_64" "Simulator"
            buildMedialibrary "$PLATFORM_NAME" "aarch64" "Simulator"
            buildMedialibrary "$PLATFORM_NAME" "aarch64" "OS"
        else
            buildMedialibrary "$PLATFORM_NAME" "i386" "Simulator"
            buildMedialibrary "$PLATFORM_NAME" "x86_64" "Simulator"
            buildMedialibrary "$PLATFORM_NAME" "aarch64" "Simulator"
            buildMedialibrary "$PLATFORM_NAME" "armv7" "OS"
            buildMedialibrary "$PLATFORM_NAME" "armv7s" "OS"
            buildMedialibrary "$PLATFORM_NAME" "aarch64" "OS"
        fi
    else
        platform="OS"

        if isSimulatorArch $ARCH; then
            platform="Simulator"
        fi
        buildMedialibrary "$PLATFORM_NAME" "$ARCH" "$platform"
    fi

else
    log "warning" "Build of Medialibrary skipped..."
fi

if [ "$CLEAN" = "yes" ]; then
    xcodebuild -alltargets clean
    log "info" "Xcode build cleaned!"
fi
collectBuiltJPEGLibs
collectBuiltSQliteLibs
collectBuiltMedialibraryLibs

rm -f $ROOT_DIR/Resources/dependencies.xcconfig
touch $ROOT_DIR/Resources/dependencies.xcconfig
echo "// This file is autogenerated by $(basename $0)" >> $ROOT_DIR/Resources/dependencies.xcconfig
echo "LIBJPEG_LIBRARIES_SIMULATOR=$BUILTJPEGLIBSSIM" >> $ROOT_DIR/Resources/dependencies.xcconfig
echo "SQLITE_LIBRARIES_SIMULATOR=$BUILTSQLITELIBSSIM" >> $ROOT_DIR/Resources/dependencies.xcconfig
echo "MEDIALIBRARY_LIBRARIES_SIMULATOR=$BUILTMEDIALIBRARYLIBSSIM" >> $ROOT_DIR/Resources/dependencies.xcconfig
echo "LIBJPEG_LIBRARIES_DEVICE=$BUILTJPEGLIBSDEVICE" >> $ROOT_DIR/Resources/dependencies.xcconfig
echo "SQLITE_LIBRARIES_DEVICE=$BUILTSQLITELIBSDEVICE" >> $ROOT_DIR/Resources/dependencies.xcconfig
echo "MEDIALIBRARY_LIBRARIES_DEVICE=$BUILTMEDIALIBRARYLIBSDEVICE" >> $ROOT_DIR/Resources/dependencies.xcconfig
echo "MOBILEVLCKIT_XCFRAMEWORK=$VLCKIT_DIR" >> $ROOT_DIR/Resources/dependencies.xcconfig

if [ "$ARCH" = "all" ] || isSimulatorArch $ARCH; then
    buildXcodeproj VLCMediaLibraryKit "VLCMediaLibraryKit" ${PLATFORM_NAME_LOWERCASE}simulator
fi
if [ "$ARCH" = "all" ] || ! isSimulatorArch $ARCH; then
    buildXcodeproj VLCMediaLibraryKit "VLCMediaLibraryKit" ${PLATFORM_NAME_LOWERCASE}os
fi

if [ "$CREATE_XCFRAMEWORK" = "yes" ]; then
    createFramework "VLCMediaLibraryKit"
fi
