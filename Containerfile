FROM docker.io/kalilinux/kali-rolling AS builder

# Compile the Go tools (nuclei + the cloud Go tools and kics) here so the build
# toolchain (golang etc.) never lands in the final image; only the binaries are
# copied across.
ENV PIP_NO_CACHE_DIR=1
COPY build/00-go-installs.sh /build/00-go-installs.sh
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/00-go-installs.sh

FROM docker.io/kalilinux/kali-rolling

ENV SHELL=/bin/bash
ENV LANG=en_GB.UTF-8
# keep pip/pipx from caching downloaded wheels into the image layers
ENV PIP_NO_CACHE_DIR=1
# pipx installs apps into /root/.local/bin; put it on PATH for build steps and runtime
ENV PATH=/root/.local/bin:$PATH

COPY config/bashrc /root/.bashrc
COPY config/bashrc.d/ /root/.bashrc.d/
COPY config/bash-color-prompt.sh /etc/profile.d/
COPY config/nvim/ /root/.config/nvim/
COPY config/tmux.conf /root/.tmux.conf
COPY config/tmux/ /root/.tmux/
COPY build /build

RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/10-tools.sh

RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/20-manual-installs.sh

RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/25-aws-tools.sh

RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/26-azure-tools.sh

RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/27-kubernetes-tools.sh

RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/28-docker-iac-tools.sh

RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/29-multicloud-tools.sh

RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/30-config.sh

RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/40-wordlists.sh

# binaries compiled in the builder stage (keeps golang and build leftovers out of this image)
COPY --from=builder /usr/local/bin/nuclei /usr/local/bin/nuclei

# cloud Go tools + kics compiled in the builder stage
COPY --from=builder /usr/local/bin/cloudfox /usr/local/bin/cloudfox
COPY --from=builder /usr/local/bin/aws-enumerator /usr/local/bin/aws-enumerator
COPY --from=builder /usr/local/bin/GoAWSConsoleSpray /usr/local/bin/GoAWSConsoleSpray
COPY --from=builder /usr/local/bin/kics /usr/local/bin/kics
COPY --from=builder /opt/kics /opt/kics

# pre-fetch nuclei templates now that the nuclei binary is in place
RUN --mount=type=tmpfs,dst=/tmp nuclei -ut

WORKDIR /root
# plain tools container: drop into a shell. Run with --privileged --network host
# for raw network access and shell catching.
CMD ["/bin/bash"]
