#!/usr/bin/env bash

set -e

ZIP="zip"
VERSION=""
COMPRESSION_FORMAT="zip"
ENABLE_PODS_COMMANDS=no
STABLE_UPLOAD_URL="https://download.videolan.org/pub/cocoapods/prod/"

usage()
{
cat << EOF
usage: $0 [options]

OPTIONS
    -t Use tar
    -p Enable Cocoapods related commands for release
    -z Use zip(default)
    -v Version
    -h Help
EOF
}

while getopts "hptzv:" OPTION
do
     case $OPTION in
         h)
            usage
            exit 1
            ;;
         p)
             ENABLE_PODS_COMMANDS=yes
             ;;
         t)
             COMPRESSION_FORMAT="tar.xz"
             ;;
         z)
             COMPRESSION_FORMAT="${ZIP}"
             ;;
         v)
             VERSION=$OPTARG
             ;;
         \?)
            usage
            exit 1
            ;;
     esac
done
shift "$((OPTIND-1))"

TARGET="VLCMediaLibraryKit"
ROOT_DIR="$(dirname "$(pwd)")"
PODSPEC="VLCMediaLibraryKit.podspec"
MEDIALIBRARY_HASH=""
VLCMEDIALIBRARYKIT_HASH=""
DISTRIBUTION_PACKAGE=""
DISTRIBUTION_PACKAGE_SHA=""

##################
# Helper methods #
##################

spushd()
{
    pushd $1 2>&1> /dev/null
}

spopd()
{
    popd 2>&1> /dev/null
}

log()
{
    local green='\033[1;32m'
    local orange='\033[1;91m'
    local red='\033[1;31m'
    local normal='\033[0m'
    local color=$green
    local msgType=$1

    if [ "$1" = "Warning" ]; then
        color=$orange
        msgType="Warning"
    elif [ "$1" = "Error" ]; then
        color=$red
        msgType="Error"
    fi
    echo -e "[${color}${msgType}${normal}] $2"
}

clean()
{
    log "Info" "Starting cleaning..."
    if [ -d "build" ]; then
        rm -rf "$ROOT_DIR/build"
    else
        log "Warning" "Build directory not found!"
    fi
    log "Info" "Build directory cleaned"
}

getVLCHashes()
{
    VLCMEDIALIBRARYKIT_HASH=$(git rev-parse --short HEAD)
    MEDIALIBRARY_HASH=`awk -F'"' '/TESTED_HASH=/ {print $2}' buildVLCMediaLibraryKit.sh`
}

packageBuild()
{
    spushd "build"
        local packageName="${TARGET}-${VERSION}-${VLCMEDIALIBRARYKIT_HASH}-${MEDIALIBRARY_HASH}.${COMPRESSION_FORMAT}"
        local toPackage="VLCMediaLibraryKit.framework COPYING"

        cp ../COPYING .
        if [ "$COMPRESSION_FORMAT" = "$ZIP" ]; then
            zip -r $packageName $toPackage
        fi

        if [ "$COMPRESSION_FORMAT" = "$TAR" ]; then
            tar -cJf $packageName $toPackage
        fi
        DISTRIBUTION_PACKAGE="$packageName"
        DISTRIBUTION_PACKAGE_SHA=$(shasum -a 256 "$packageName" | cut -d " " -f 1)
        log "Info" "Distribution package generated at: `pwd`"
        log "Info" "Distribution package checksum: ${DISTRIBUTION_PACKAGE_SHA}"
    spopd #build
}

bumpPodspec()
{
    local podVersion="s.version      = '${VERSION}'"
    local uploadURL=":http => '${UPLOAD_URL}${DISTRIBUTION_PACKAGE}'"
    local podSHA=":sha256 => '${DISTRIBUTION_PACKAGE_SHA}'"

    perl -i -pe's#s.version.*#'"${podVersion}"'#g' $1
    perl -i -pe's#:http.*#'"${uploadURL},"'#g' $1
    perl -i -pe's#:sha256.*#'"${podSHA}"'#g' $1
}

gitCommit()
{
    local podspec="$1"

    git add "$podspec"
    git commit -m "${podspec}: Update version to ${VERSION}"
}

checkIfExistOnRemote()
{
    if ! curl --head --silent "$1" | head -n 1 | grep -q 404; then
        return 0
    else
        return 1
    fi
}

uploadPackage()
{
    # handle upload of distribution package.

    if [ "$DISTRIBUTION_PACKAGE" = "" ]; then
        log "Error" "Distribution package not found!"
        exit 1
    fi

    while read -r -n 1 -p "The package is ready please upload it to \"${UPLOAD_URL}\", press a key to continue when uploaded [y,a,r]: " response
    do
        printf '\r'
        case $response in
            y)
                log "Info" "Checking for: '${UPLOAD_URL}${DISTRIBUTION_PACKAGE}'..."
                if checkIfExistOnRemote "${UPLOAD_URL}${DISTRIBUTION_PACKAGE}"; then
                    log "Info" "Package found on ${UPLOAD_URL}!"
                    break
                fi
                log "Warning" "Package not found on ${UPLOAD_URL}!"
                ;;
            a)
                log "Warning" "Aborting deployment process!"
                exit 1
                ;;
            *)
                ;;
        esac
    done
}

##################
# Command Center #
##################

if [ "$CLEAN" = "yes" ]; then
    clean
fi

UPLOAD_URL=${STABLE_UPLOAD_URL}

if [ "$VERSION" = "" ]; then
    log "Error" "Failed to retreive version. Please precise a valid version!"
    exit 1
fi

getVLCHashes
packageBuild $options
if [ "$ENABLE_PODS_COMMANDS" = "yes" ]; then
    bumpPodspec $PODSPEC
    gitCommit $PODSPEC
fi
