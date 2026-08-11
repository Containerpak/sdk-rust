FROM ghcr.io/containerpak/base-sdk:main AS build

ARG RUST_VERSION=1.95.0
ARG RUSTUP_VERSION=1.29.0
ARG RUSTUP_SHA256=4acc9acc76d5079515b46346a485974457b5a79893cfb01112423c89aeb5aa10

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl && \
    curl -fsSLo /tmp/rustup-init "https://static.rust-lang.org/rustup/archive/${RUSTUP_VERSION}/x86_64-unknown-linux-gnu/rustup-init" && \
    echo "${RUSTUP_SHA256}  /tmp/rustup-init" | sha256sum -c - && \
    chmod +x /tmp/rustup-init && \
    RUSTUP_HOME=/opt/rustup CARGO_HOME=/opt/cargo \
    /tmp/rustup-init -y --profile minimal --default-toolchain "${RUST_VERSION}" --no-modify-path

FROM ghcr.io/containerpak/base-sdk:main

COPY --from=build /opt/rustup /opt/rustup
COPY --from=build /opt/cargo /opt/cargo

RUN for binary in cargo rustc rustdoc rustfmt rustup; do \
        ln -s "/opt/cargo/bin/${binary}" "/usr/local/bin/${binary}"; \
    done

ENV RUSTUP_HOME=/opt/rustup
ENV CARGO_HOME=/opt/cargo
ENV PATH=/usr/local/bin:/opt/cargo/bin:${PATH}
