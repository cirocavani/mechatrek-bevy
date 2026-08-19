FROM ubuntu:26.04
ARG USER_ID=1000
ARG GROUP_ID=1000

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
ENV ANDROID_HOME="/home/mechatrek/Android/Sdk"
ENV NDK_HOME="${ANDROID_HOME}/ndk/27.0.12077973"
ENV PATH="/home/mechatrek/.cargo/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/cmdline-tools/latest/bin:${PATH}"

# https://askubuntu.com/questions/1513927/ubuntu-24-04-docker-images-now-includes-user-ubuntu-with-uid-gid-1000
# https://bugs.launchpad.net/cloud-images/+bug/2005129
RUN touch /var/mail/ubuntu && \
    chown ubuntu /var/mail/ubuntu && \
    userdel -r ubuntu

RUN apt update && \
    apt install -y --no-install-recommends \
    ca-certificates \
    curl \
    sudo \
    make \
    tar \
    xz-utils \
    zip \
    unzip \
    libssl-dev \
    lldb \
    clang \
    lld \
    pkg-config \
    libasound2-dev \
    libudev-dev \
    libx11-dev \
    libxkbcommon-x11-0 \
    libwayland-dev \
    libxkbcommon-dev \
    mesa-vulkan-drivers \
    mesa-utils \
    vulkan-tools \
    openjdk-17-jdk-headless \
    openjdk-17-jre-headless \
    java-common && \
    apt distclean

RUN update-alternatives --install /usr/bin/lldb-dap lldb-dap /usr/bin/lldb-dap-21 1000

RUN update-java-alternatives --set java-1.17.0-openjdk-amd64

RUN groupadd --gid ${GROUP_ID} mechatrek
RUN useradd -m --uid ${USER_ID} --gid ${GROUP_ID} -G sudo mechatrek
RUN passwd -d mechatrek
RUN echo "mechatrek ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/010_mechatrek-nopasswd

USER mechatrek
WORKDIR /home/mechatrek


# Rust Toolchain install

RUN curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable -y

RUN curl --proto "=https" --tlsv1.2 -sSfL https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash

RUN cargo binstall -y \
    cargo-edit \
    cargo-sort \
    cargo-update \
    zellij \
    nu


# WebAssembly tools

RUN rustup target add wasm32-unknown-unknown

RUN cargo binstall -y \
    wasm-bindgen-cli@0.2.127 \
    simple-http-server


# Android tools

RUN curl --proto '=https' --tlsv1.2 -sSfLO https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip

RUN unzip commandlinetools-linux-13114758_latest.zip

RUN mkdir -p "$ANDROID_HOME/licenses"

RUN echo "24333f8a63b6825ea9c5514f83c2829b004d1fee" > "$ANDROID_HOME/licenses/android-sdk-license"

RUN cmdline-tools/bin/sdkmanager \
    --sdk_root=${ANDROID_HOME} \
    --install \
    'build-tools;36.0.0' \
    'cmake;3.22.1' \
    'cmdline-tools;latest' \
    'ndk;27.0.12077973' \
    platform-tools \
    'platforms;android-35'

RUN rm -rf cmdline-tools/ commandlinetools-linux-13114758_latest.zip

COPY --chown=mechatrek android/gradlew ./gradlew

COPY --chown=mechatrek android/gradle/ ./gradle/

RUN chmod +x ./gradlew && ./gradlew --version

RUN rm -rf gradlew gradle/

RUN rustup target add \
    aarch64-linux-android \
    x86_64-linux-android

RUN cargo binstall -y cargo-ndk


# Helix Editor install

RUN mkdir -p ~/.local/bin/ ~/.local/helix/ ~/.config/helix/
RUN curl --proto "=https" --tlsv1.2 -sSfL https://github.com/helix-editor/helix/releases/download/25.07.1/helix-25.07.1-x86_64-linux.tar.xz | \
    tar -xJC ~/.local/helix --strip-components=1
RUN ln -s ~/.local/helix/hx ~/.local/bin/
RUN ln -s ~/.local/helix/runtime ~/.config/helix/

RUN rustup component add rust-analyzer


RUN rm -rf ~/.cargo/{registry,git}

VOLUME ["/home/mechatrek/project", "/home/mechatrek/.cargo/registry", "/home/mechatrek/.cargo/git", "/home/mechatrek/.gradle/caches"]
WORKDIR /home/mechatrek/project

CMD ["/bin/bash", "-l"]
