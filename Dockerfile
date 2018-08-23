FROM kalilinux/kali-linux-docker

LABEL maintainer "https://github.com/l50"

COPY entrypoint/msfdev-entrypoint.sh /
COPY env /.env

EXPOSE 4444

RUN build_deps='autoconf \
	        build-essential \
        	curl \
	        bison \
	        libapr1 \
          	libaprutil1 \
	        libcurl4-openssl-dev \
                libpq-dev \
        	libgmp3-dev \
                libssl-dev \
                libsvn1 \
                libtool \
        	libreadline6-dev \
	        libxml2-dev \
        	locate \
	        ncurses-dev \
	        xsel \
	        zlib1g-dev' \
# Packages for dev that are not required by msf
&& dev_pkgs='tmux \
	     vim' \
&& set -x \
&& echo "[INFO] Installing Dependencies..." \
&& apt-get -y update \
&& apt install -y $build_deps \
        $dev_pkgs \
	git-core \
        libpcap-dev \
        libsqlite3-dev \
	libxslt-dev \
        libxml2 \
	libyaml-dev \
	openssl \
	postgresql \
	postgresql-contrib \
	sudo \
	wget \
        zlib1g \
&& chmod +x /msfdev-entrypoint.sh \
&& /bin/bash /msfdev-entrypoint.sh \
&& echo "[INFO] Removing Build Dependencies..." \
&& apt-get autoremove --purge -y $build_deps \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT service postgresql restart && /bin/bash
