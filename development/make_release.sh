#!/usr/bin/env bash
set -eu

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd ${PROJECT_DIR}

echo
echo "Linux x86_64 binary release"
echo

docker run --rm -it --platform linux/amd64 \
-v $PWD:/home/mechatrek/project \
-v $HOME/.cargo/registry:/home/mechatrek/.cargo/registry \
-v $HOME/.cargo/git:/home/mechatrek/.cargo/git \
mechatrek-bevy-ubuntu:latest \
make release-x86_64 package-x86_64

echo
echo "Linux aarch64 binary release"
echo

docker run --rm -it --platform linux/arm64 \
-v $PWD:/home/mechatrek/project \
-v $HOME/.cargo/registry:/home/mechatrek/.cargo/registry \
-v $HOME/.cargo/git:/home/mechatrek/.cargo/git \
mechatrek-bevy-debian:latest \
make release-aarch64 package-aarch64

echo
echo "WASM package (site)"
echo

docker run --rm -it --platform linux/amd64 \
-v ${PWD}:/home/mechatrek/project \
-v ${HOME}/.cargo/registry:/home/mechatrek/.cargo/registry \
-v ${HOME}/.cargo/git:/home/mechatrek/.cargo/git \
mechatrek-bevy-ubuntu:latest \
make build-web package-web

echo
echo "APK release"
echo

docker run --rm -it --platform linux/amd64 \
-v ${PWD}:/home/mechatrek/project \
-v ${HOME}/.cargo/registry:/home/mechatrek/.cargo/registry \
-v ${HOME}/.cargo/git:/home/mechatrek/.cargo/git \
-v ${HOME}/.gradle/caches:/home/mechatrek/.gradle/caches \
mechatrek-bevy-ubuntu:latest \
make build-android-lib build-android-apk package-apk

echo
echo "Release Assets"
echo

ls -alh dist/
