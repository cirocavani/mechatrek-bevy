FROM ubuntu:26.04
ARG USER_ID=1000
ARG GROUP_ID=1000

ENV DEBIAN_FRONTEND=noninteractive \
    PATH="/home/mechatrek/.cargo/bin:${PATH}"

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
    vulkan-tools && \
    apt distclean

RUN update-alternatives --install /usr/bin/lldb-dap lldb-dap /usr/bin/lldb-dap-21 1000

RUN groupadd --gid ${GROUP_ID} mechatrek
RUN useradd -m --uid ${USER_ID} --gid ${GROUP_ID} -G sudo mechatrek
RUN passwd -d mechatrek
RUN echo "mechatrek ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/010_mechatrek-nopasswd

USER mechatrek
WORKDIR /home/mechatrek


# Rust Toolchain install

RUN curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | \
    sh -s -- --default-toolchain stable -y

RUN curl --proto "=https" --tlsv1.2 -sSfL https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | \
    bash

RUN cargo binstall -y \
    cargo-edit \
    cargo-sort \
    cargo-update \
    zellij

RUN rustup target add wasm32-unknown-unknown

RUN cargo binstall -y \
    wasm-bindgen-cli@0.2.127 \
    simple-http-server

RUN rm -rf ~/.cargo/{registry,git}


# Helix Editor install

RUN mkdir -p ~/.local/bin/ ~/.local/helix/ ~/.config/helix/
RUN curl --proto "=https" --tlsv1.2 -sSfL https://github.com/helix-editor/helix/releases/download/25.07.1/helix-25.07.1-x86_64-linux.tar.xz | \
    tar -xJC ~/.local/helix --strip-components=1
RUN ln -s ~/.local/helix/hx ~/.local/bin/
RUN ln -s ~/.local/helix/runtime ~/.config/helix/

RUN rustup component add rust-analyzer


VOLUME ["/home/mechatrek/project", "/home/mechatrek/.cargo/registry", "/home/mechatrek/.cargo/git"]
WORKDIR /home/mechatrek/project

CMD ["/bin/bash", "-l"]
