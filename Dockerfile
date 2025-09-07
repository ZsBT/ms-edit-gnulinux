# syntax=docker/dockerfile:1
ARG UBUNTUDIST=latest

FROM ubuntu:$UBUNTUDIST

RUN apt -qq update && apt -y install gcc git
RUN apt -y install xz-utils libicu*

RUN apt -y install wget

RUN git clone --depth=1 --single-branch https://github.com/microsoft/edit /usr/src/ms-edit
WORKDIR /usr/src/ms-edit

RUN wget -qO /tmp/rustup.sh https://sh.rustup.rs && chmod +x /tmp/rustup.sh

ENV SHELL=/bin/bash
SHELL ["/bin/bash", "-c"]

RUN <<EOB
    /tmp/rustup.sh -y
    source "$HOME/.cargo/env"
    rustup component add rust-src --toolchain nightly-x86_64-unknown-linux-gnu
    EDIT_CFG_ICU_RENAMING_AUTO_DETECT=true
    EDIT_CFG_ICUUC_SONAME=$(ldconfig -p |grep -Eo 'libicuuc.so.[0-9]+' |head -1)
    EDIT_CFG_ICUI18N_SONAME=$(ldconfig -p |grep -Eo 'libicui18n.so.[0-9]+' |head -1)
    RUSTC_BOOTSTRAP=1
    cargo build --config .cargo/release.toml --release
EOB



RUN /usr/src/ms-edit/target/release/edit -v
RUN xz -vf /usr/src/ms-edit/target/release/edit

