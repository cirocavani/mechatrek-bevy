#!/usr/bin/env bash
set -eu

VERSION=v0.0.1
PKG_NAME=mechatrek-bevy-${VERSION}

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RELEASE_DIR=${PROJECT_DIR}/dist/${VERSION}
PKG_FILE=${RELEASE_DIR}/${PKG_NAME}


cd ${PROJECT_DIR}
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

cd web
zip -r ${PKG_FILE}-web.zip .
cd ..



echo
echo "APK release"
echo

. android-env.sh

rm -rf android/app/src/main/jniLibs/

cargo ndk \
-P 31 \
-t arm64-v8a \
-t x86_64 \
-o android/app/src/main/jniLibs \
build \
--lib \
--profile mobile-release \
--features log-max,android

cd android/

./gradlew --warning-mode all clean build

cd ..

cp android/app/build/outputs/apk/debug/app-debug.apk ${PKG_FILE}.apk



echo
echo "Release Assets"
echo

ls -alh ${RELEASE_DIR}
