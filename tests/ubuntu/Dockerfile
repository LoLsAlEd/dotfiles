FROM ubuntu:26.04

# Only bootstrap prerequisites; the dotfiles must install the shell tools.
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates curl git sudo \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --shell /bin/bash dotfiles \
    && printf 'dotfiles ALL=(ALL) NOPASSWD: ALL\n' > /etc/sudoers.d/dotfiles \
    && chmod 0440 /etc/sudoers.d/dotfiles

COPY . /opt/dotfiles
RUN chown -R dotfiles:dotfiles /opt/dotfiles

ENV TERM=xterm-256color
ENV LANG=C.UTF-8
WORKDIR /opt/dotfiles
ENTRYPOINT ["bash", "tests/ubuntu/check-bootstrap.sh"]
