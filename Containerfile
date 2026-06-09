FROM docker.io/kalilinux/kali-rolling AS builder

# Compile the Go tools and John the Ripper here so the build toolchain
# (golang etc.) never lands in the final image; only the binaries are copied across.
ENV PIP_NO_CACHE_DIR=1
COPY build/00-go-installs.sh /build/00-go-installs.sh
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/00-go-installs.sh

# cloud Go tools + kics (copied into the final image via COPY --from=builder below)
COPY build/05-cloud-go-installs.sh /build/05-cloud-go-installs.sh
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/05-cloud-go-installs.sh

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
    /build/25-cloud-tools.sh

RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/30-config.sh

RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/40-wordlists.sh

# binaries compiled in the builder stage (keeps golang and build leftovers out of this image)
COPY --from=builder /usr/local/bin/brutespray /usr/local/bin/brutespray
COPY --from=builder /usr/local/bin/gowitness /usr/local/bin/gowitness
COPY --from=builder /usr/local/bin/wpprobe /usr/local/bin/wpprobe
COPY --from=builder /usr/local/bin/gobuster /usr/local/bin/gobuster
COPY --from=builder /usr/local/bin/nuclei /usr/local/bin/nuclei
COPY --from=builder /usr/local/bin/ldapnomnom /usr/local/bin/ldapnomnom
COPY --from=builder /usr/local/bin/traitor /usr/local/bin/traitor
COPY --from=builder /usr/local/bin/windapsearch /usr/local/bin/windapsearch
COPY --from=builder /opt/john-the-ripper /opt/john-the-ripper

# cloud Go tools + kics compiled in the builder stage
COPY --from=builder /usr/local/bin/cloudfox /usr/local/bin/cloudfox
COPY --from=builder /usr/local/bin/aws-enumerator /usr/local/bin/aws-enumerator
COPY --from=builder /usr/local/bin/GoAWSConsoleSpray /usr/local/bin/GoAWSConsoleSpray
COPY --from=builder /usr/local/bin/kics /usr/local/bin/kics
COPY --from=builder /opt/kics /opt/kics

# pre-fetch nuclei templates now that the nuclei binary is in place
RUN --mount=type=tmpfs,dst=/tmp nuclei -ut

WORKDIR /root
# boot systemd so in-container services (docker, postgresql, sshd, …) can be managed;
# run the container with --privileged
CMD /sbin/init
