# The Book of the Machine - Mechatrek Bevy Project

> Bevy is a refreshingly simple data-driven game engine built in Rust.

<https://bevyengine.org/>

<https://github.com/bevyengine/bevy>

## Setup

Pre-requisites:

- Rust Toolchain
- Docker Engine / CLI
- Vulkan support
- Wayland window system

Setup instruction [here](./development/setup.md).

## Development

### Project

```sh
# Run tests from `tests` modules
make test

# Run lint on rs files in `src` directory
make lint

# Format rs files
make format

# Build all targets
make build

# Remove builds
make clean

# Build a release and dist package: dist/mechatrek-bevy-<version>-linux-x86_64.tar.gz
# (requires a x86_64 system or Docker with QEMU)
make release-x86_64 package-x86_64

# Build a release and dist package: dist/mechatrek-bevy-<version>-linux-aarch64.tar.gz
# (requires an aarch64 system or Docker with QEMU)
make release-aarch64 package-aarch64
```

For more datials on release procedure, see [`make_release.sh`](./development/make_release.sh).

### WebAssembly

```sh
# Build WASM target
make build-wasm

# Build Web App package
make build-web

# Run Web App server
make serve-web

# Run Web App browser
# (open a Chrome App window with a second Dev Tools window)
# (assumes NVIDIA Discrete GPU)
make open-web

# Create a dist package with the web content (no prefix folder): dist/mechatrek-bevy-<version>-web.zip
make package-web
```

### Android

```sh
# Build Rust dynamic library (.so)
make build-android-lib

# Build Android project (Gradle)
make build-android-apk

# Instal debug APK (TCP/IP device - Emulator)
make install-apk-emulator

# Install debug APK (USB device)
make install-apk-device

# Run Android Emulator
# (open an Android interface)
# (assumes NVIDIA Discrete GPU)
make open-android-emulator

# Alias for build and install APK on device
make android-device

# Alias for build and install APK on emulator
make android-emulator

# Create a dist package: dist/mechatrek-bevy-<version>.apk
make package-apk
```

### Docker

#### X86_64 Ubuntu 26.04 (development)

```sh
# Build Docker Image `mechatrek-bevy-ubuntu`
make build-docker-ubuntu-amd64

# Execute `cargo run` in a container based on `mechatrek-bevy-ubuntu`
# (open a window using Wayland)
make docker-ubuntu-amd64-run
make docker-ubuntu-amd64-nvidia-run

# Alias for build and run with ubuntu-amd64
# (open a window using Wayland)
make docker-ubuntu-amd64
make docker-ubuntu-amd64-nvidia
```

#### Aarch64 Debian 13 (emulator)

Target Raspberry Pi.

```sh
# Build Docker Image `mechatrek-bevy-debian`
make build-docker-debian-arm64

# Execute `cargo run` in a container based on `mechatrek-bevy-debian`
# (open a window using Wayland)
make docker-debian-arm64-run

# Alias for build and run with debian-arm64
# (open a window using Wayland)
make docker-debian-arm64
```

#### WebAssemby (WASM)

```sh
# Build Docker Image `mechatrek-bevy-ubuntu`
make build-docker-ubuntu-amd64

# Build WASM binary at web folder
make docker-build-web

# Run HTTP server for web folder - http://127.0.0.1:8000
make docker-serve-web
```

#### Android

```sh
# Build Docker Image `mechatrek-bevy-ubuntu`
make build-docker-ubuntu-amd64

# Build APK (android/app/build/outputs/apk/debug/app-debug.apk)
make docker-build-android-apk
```

## Making Of Documentation

[README](./garage/workbench/README.md)
