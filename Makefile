SHELL = /bin/bash

#
# Development
#

.PHONY: test
test:
	cargo test --all-targets --all-features

.PHONY: lint
lint:
	cargo clippy --all-targets --all-features -- -D warnings

.PHONY: format
format:
	cargo fmt --all -- --emit files

.PHONY: build
build:
	cargo build --features dev,wayland

.PHONY: release-aarch64
release-aarch64:
	cargo build \
	--profile release-lto \
	--target aarch64-unknown-linux-gnu \
	--features log-max,wayland

.PHONY: package-aarch64
package-aarch64:
	PKG_VERSION="$$(cargo get package.version)" && \
	PKG_NAME="mechatrek-bevy-$${PKG_VERSION}-linux-aarch64" && \
	PKG_DIR="dist/$${PKG_NAME}" && \
	PKG_FILE="$${PKG_DIR}.tar.gz" && \
	rm -rf "$${PKG_DIR}" && \
	mkdir -p "$${PKG_DIR}" && \
	cp target/aarch64-unknown-linux-gnu/release-lto/mechatrek-bevy "$${PKG_DIR}" && \
	cp -r assets "$${PKG_DIR}" && \
	tar czvf "$${PKG_FILE}" -C dist "$${PKG_NAME}" && \
	rm -rf "$${PKG_DIR}"

.PHONY: release-x86_64
release-x86_64:
	cargo build \
	--profile release-lto \
	--target x86_64-unknown-linux-gnu \
	--features log-max,wayland

.PHONY: package-x86_64
package-x86_64:
	PKG_VERSION="$$(cargo get package.version)" && \
	PKG_NAME="mechatrek-bevy-$${PKG_VERSION}-linux-x86_64" && \
	PKG_DIR="dist/$${PKG_NAME}" && \
	PKG_FILE="$${PKG_DIR}.tar.gz" && \
	rm -rf "$${PKG_DIR}" && \
	mkdir -p "$${PKG_DIR}" && \
	cp target/x86_64-unknown-linux-gnu/release-lto/mechatrek-bevy "$${PKG_DIR}" && \
	cp -r assets "$${PKG_DIR}" && \
	tar czvf "$${PKG_FILE}" -C dist "$${PKG_NAME}" && \
	rm -rf "$${PKG_DIR}"

.PHONY: run
run:
	cargo run --features dev,wayland

.PHONY: clean
clean:
	cargo clean

.PHONY: upgrade
upgrade:
	cargo upgrade --compatible --verbose
	cargo update --verbose

#
# WebAssembly
#

.PHONY: build-wasm
build-wasm:
	cargo build \
	--profile wasm-release \
	--target wasm32-unknown-unknown \
	--features log-max

.PHONY: build-web
build-web: build-wasm
	rm -f web/mechatrek_bevy*;
	wasm-bindgen \
	--out-name mechatrek_bevy \
	--out-dir web/ \
	--target web \
	target/wasm32-unknown-unknown/wasm-release/mechatrek-bevy.wasm

.PHONY: package-web
package-web:
	PKG_VERSION="$$(cargo get package.version)" && \
	PKG_FILE="dist/mechatrek-bevy-$${PKG_VERSION}-web.zip" && \
	cd web && \
	zip -r "../$${PKG_FILE}" *

.PHONY: serve-web
serve-web:
	simple-http-server -i --nocache web/

.PHONY: open-web
open-web: export __NV_PRIME_RENDER_OFFLOAD=1
open-web: export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
open-web: export __GLX_VENDOR_LIBRARY_NAME=nvidia
open-web: export __VK_LAYER_NV_optimus=NVIDIA_only
open-web: export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json
open-web: 
	google-chrome \
	--no-default-browser-check \
	--no-first-run \
	--disable-sync \
	--disable-translate \
	--disable-background-networking \
	--safebrowsing-disable-auto-update \
	--safebrowsing-disable-download-protection \
	--metrics-recording-only \
	--enable-logging \
	--log-level=1 \
	--full-memory-crash-report \
	--auto-open-devtools-for-tabs \
	--app=http://127.0.0.1:8000/

#
# Android
#

.PHONY: build-android-lib
build-android-lib:
	@if [ -z "$$ANDROID_HOME" ]; then \
		echo 'loading android-env.sh'; \
		. android-env.sh; \
	fi && \
	rm -rf android/app/src/main/jniLibs/ && \
	cargo ndk \
	-P 31 \
	-t arm64-v8a \
	-t x86_64 \
	-o android/app/src/main/jniLibs \
	build \
	--lib \
	--profile mobile-release \
	--features log-max,android

.PHONY: build-android-apk
build-android-apk:
	@if [ -z "$$ANDROID_HOME" ]; then \
		echo 'loading android-env.sh'; \
		. android-env.sh; \
	fi && \
	cd android/ && \
	./gradlew clean build --no-daemon --warning-mode all 

.PHONY: package-apk
package-apk:
	PKG_VERSION="$$(cargo get package.version)" && \
	PKG_FILE="dist/mechatrek-bevy-$${PKG_VERSION}.apk" && \
	cp android/app/build/outputs/apk/debug/app-debug.apk "$${PKG_FILE}"

.PHONY: install-apk-emulator
install-apk-emulator:
	@if [ -z "$$ANDROID_HOME" ]; then \
		echo 'loading android-env.sh'; \
		. android-env.sh; \
	fi && \
	adb -e install android/app/build/outputs/apk/debug/app-debug.apk

.PHONY: install-apk-device
install-apk-device:
	@if [ -z "$$ANDROID_HOME" ]; then \
		echo 'loading android-env.sh'; \
		. android-env.sh; \
	fi && \
	adb -d install android/app/build/outputs/apk/debug/app-debug.apk

# WARNING
# - `-gpu host` dows not work at the moment (app closes after opening window)
# - `-gpu swiftshader_indirect` renders 3D scene but input does not work (camera movement, button)
 .PHONY: open-android-emulator
open-android-emulator: export __NV_PRIME_RENDER_OFFLOAD=1
open-android-emulator: export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
open-android-emulator: export __GLX_VENDOR_LIBRARY_NAME=nvidia
open-android-emulator: export __VK_LAYER_NV_optimus=NVIDIA_only
open-android-emulator: export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json
open-android-emulator:
	@if [ -z "$$ANDROID_HOME" ]; then \
		echo 'loading android-env.sh'; \
		. android-env.sh; \
	fi && \
	emulator -avd Pixel_9_Pro_API_35 -gpu host -netdelay none -netspeed full -wipe-data

.PHONY: android-device
android-device: build-android-lib build-android-apk install-apk-device

.PHONY: android-emulator
android-emulator: build-android-lib build-android-apk install-apk-emulator

#
# Docker (local) - Development Images
#

# Docker / Ubuntu X86_64

.PHONY: build-docker-ubuntu-amd64
build-docker-ubuntu-amd64:
	docker build \
	--progress plain \
	--platform linux/amd64 \
	--build-arg USER_ID=`id -u` \
	--build-arg GROUP_ID=`id -g` \
	-t mechatrek-bevy-ubuntu:latest \
	-f docker/ubuntu/Dockerfile \
	.

.PHONY: docker-ubuntu-amd64-run
docker-ubuntu-amd64-run:
	docker run --rm -it --platform linux/amd64 \
	-e WAYLAND_DISPLAY=${WAYLAND_DISPLAY} \
	-e XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR} \
	-v ${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}:${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY} \
	-v /etc/machine-id:/etc/machine-id:ro \
	-e CARGO_TARGET_DIR=/home/mechatrek/project/target/x86_64-unknown-linux-gnu \
	-v ${PWD}:/home/mechatrek/project \
	-v ${HOME}/.cargo/registry:/home/mechatrek/.cargo/registry \
	-v ${HOME}/.cargo/git:/home/mechatrek/.cargo/git \
	mechatrek-bevy-ubuntu:latest \
	make run

.PHONY: docker-ubuntu-amd64-nvidia-run
docker-ubuntu-amd64-nvidia-run:
	docker run --rm -it --platform linux/amd64 \
	--runtime nvidia \
	--gpus all \
	--device /dev/dri \
	--group-add $(shell getent group video | cut -d ':' -f 3) \
	--group-add $(shell getent group render | cut -d ':' -f 3) \
	-e NVIDIA_DRIVER_CAPABILITIES=all \
	-e WAYLAND_DISPLAY=${WAYLAND_DISPLAY} \
	-e XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR} \
	-v ${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}:${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY} \
	-v /etc/machine-id:/etc/machine-id:ro \
	-e CARGO_TARGET_DIR=/home/mechatrek/project/target/x86_64-unknown-linux-gnu \
	-v ${PWD}:/home/mechatrek/project \
	-v ${HOME}/.cargo/registry:/home/mechatrek/.cargo/registry \
	-v ${HOME}/.cargo/git:/home/mechatrek/.cargo/git \
	mechatrek-bevy-ubuntu:latest \
	make run

.PHONY: docker-ubuntu-amd64
docker-ubuntu-amd64: build-docker-ubuntu-amd64 docker-ubuntu-amd64-run

.PHONY: docker-ubuntu-amd64-nvidia
docker-ubuntu-amd64-nvidia: build-docker-ubuntu-amd64 docker-ubuntu-amd64-nvidia-run

.PHONY: docker-ubuntu-amd64-shell
docker-ubuntu-amd64-shell:
	docker run --rm -it --platform linux/amd64 \
	-e WAYLAND_DISPLAY=${WAYLAND_DISPLAY} \
	-e XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR} \
	-v ${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}:${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY} \
	-v /etc/machine-id:/etc/machine-id:ro \
	-e CARGO_TARGET_DIR=/home/mechatrek/project/target/x86_64-unknown-linux-gnu \
	-v ${PWD}:/home/mechatrek/project \
	-v ${HOME}/.cargo/registry:/home/mechatrek/.cargo/registry \
	-v ${HOME}/.cargo/git:/home/mechatrek/.cargo/git \
	mechatrek-bevy-ubuntu:latest

# Docker / Debian Aarch64

.PHONY: build-docker-debian-arm64
build-docker-debian-arm64:
	docker build \
	--progress plain \
	--platform linux/arm64 \
	--build-arg USER_ID=`id -u` \
	--build-arg GROUP_ID=`id -g` \
	-t mechatrek-bevy-debian:latest \
	-f docker/debian/Dockerfile \
	.

.PHONY: docker-debian-arm64-run
docker-debian-arm64-run:
	docker run --rm -it --platform linux/arm64 \
	-e WAYLAND_DISPLAY=${WAYLAND_DISPLAY} \
	-e XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR} \
	-v ${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}:${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY} \
	-v /etc/machine-id:/etc/machine-id:ro \
	-e CARGO_TARGET_DIR=/home/mechatrek/project/target/aarch64-unknown-linux-gnu \
	-v ${PWD}:/home/mechatrek/project \
	-v ${HOME}/.cargo/registry:/home/mechatrek/.cargo/registry \
	-v ${HOME}/.cargo/git:/home/mechatrek/.cargo/git \
	mechatrek-bevy-debian:latest \
	make run

.PHONY: docker-debian-arm64
docker-debian-arm64: build-docker-debian-arm64 docker-debian-arm64-run

.PHONY: docker-debian-arm64-shell
docker-debian-arm64-shell:
	docker run --rm -it --platform linux/arm64 \
	-e WAYLAND_DISPLAY=${WAYLAND_DISPLAY} \
	-e XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR} \
	-v ${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}:${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY} \
	-v /etc/machine-id:/etc/machine-id:ro \
	-e CARGO_TARGET_DIR=/home/mechatrek/project/target/aarch64-unknown-linux-gnu \
	-v ${PWD}:/home/mechatrek/project \
	-v ${HOME}/.cargo/registry:/home/mechatrek/.cargo/registry \
	-v ${HOME}/.cargo/git:/home/mechatrek/.cargo/git \
	mechatrek-bevy-debian:latest

# Docker / WebAssemply

.PHONY: docker-build-web
docker-build-web: IMAGE_NAME=mechatrek-bevy-ubuntu:latest
docker-build-web:
	docker run --rm -it \
	-v ${PWD}:/home/mechatrek/project \
	-v ${HOME}/.cargo/registry:/home/mechatrek/.cargo/registry \
	-v ${HOME}/.cargo/git:/home/mechatrek/.cargo/git \
	${IMAGE_NAME} \
	make build-web

.PHONY: docker-serve-web
docker-serve-web: IMAGE_NAME=mechatrek-bevy-ubuntu:latest
docker-serve-web:
	docker run --rm -it \
	-v ${PWD}:/home/mechatrek/project \
	-p 8000:8000 \
	${IMAGE_NAME} \
	make serve-web

# Docker / Android

.PHONY: docker-build-android-apk
docker-build-android-apk:
	docker run --rm -it --platform linux/amd64 \
	-v ${PWD}:/home/mechatrek/project \
	-v ${HOME}/.cargo/registry:/home/mechatrek/.cargo/registry \
	-v ${HOME}/.cargo/git:/home/mechatrek/.cargo/git \
	-v ${HOME}/.gradle/caches:/home/mechatrek/.gradle/caches \
	mechatrek-bevy-ubuntu:latest \
	make build-android-lib build-android-apk
