#!/usr/bin/env bash
set -eu

VERSION=v0.0.1
PKG_NAME=mechatrek-bevy-${VERSION}

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RELEASE_DIR=${PROJECT_DIR}/dist/${VERSION}
PKG_FILE=${RELEASE_DIR}/${PKG_NAME}

rm -rf ${RELEASE_DIR}
mkdir -p ${RELEASE_DIR}



echo
echo "Linux x86_64 binary release"
echo

docker run --rm -it --platform linux/amd64 \
-v $PWD:/home/mechatrek/project \
-v $HOME/.cargo/registry:/home/mechatrek/.cargo/registry \
-v $HOME/.cargo/git:/home/mechatrek/.cargo/git \
mechatrek-bevy-ubuntu:latest \
make release-x86_64

cp target/x86_64-unknown-linux-gnu/release-lto/mechatrek-bevy ${PKG_FILE}-linux-x86_64



echo
echo "Linux aarch64 binary release"
echo

docker run --rm -it --platform linux/arm64 \
-v $PWD:/home/mechatrek/project \
-v $HOME/.cargo/registry:/home/mechatrek/.cargo/registry \
-v $HOME/.cargo/git:/home/mechatrek/.cargo/git \
mechatrek-bevy-debian:latest \
make release-aarch64

cp target/aarch64-unknown-linux-gnu/release-lto/mechatrek-bevy ${PKG_FILE}-linux-aarch64



echo
echo "WASM package (site)"
echo

docker run --rm -it --platform linux/amd64 \
-v ${PWD}:/home/mechatrek/project \
-v ${HOME}/.cargo/registry:/home/mechatrek/.cargo/registry \
-v ${HOME}/.cargo/git:/home/mechatrek/.cargo/git \
mechatrek-bevy-ubuntu:latest \
make build-web

zip -r ${PKG_FILE}-web.zip web/*



echo
echo "APK release"
echo

docker run --rm -it --platform linux/amd64 \
-v ${PWD}:/home/mechatrek/project \
-v ${HOME}/.cargo/registry:/home/mechatrek/.cargo/registry \
-v ${HOME}/.cargo/git:/home/mechatrek/.cargo/git \
-v ${HOME}/.gradle/caches:/home/mechatrek/.gradle/caches \
mechatrek-bevy-ubuntu:latest \
make build-android-lib build-android-apk

cp android/app/build/outputs/apk/debug/app-debug.apk ${PKG_FILE}.apk



echo
echo "Release Assets"
echo

ls -alh ${RELEASE_DIR}
