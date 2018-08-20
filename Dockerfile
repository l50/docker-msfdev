FROM kalilinux/kali-linux-docker

LABEL maintainer "https://github.com/l50"

COPY entrypoint/msfdev-entrypoint.sh /
COPY env /.env

EXPOSE 4444

RUN build_deps='autoconf \
	        bison \
	        build-essential \
	        git-core \
	        libapr1 \
            	libaprutil1 \
	        libcurl4-openssl-dev \
        	libgmp3-dev \
        	libpcap-dev \
        	libpq-dev \
        	libreadline6-dev \
        	libsqlite3-dev \
        	libssl-dev \
        	libsvn1 \
        	libtool \
        	libxml2 \
	        libxml2-dev \
	        libxslt-dev \
	        libyaml-dev \
        	locate \
	        ncurses-dev \
	        xsel \
        	zlib1g \
	        zlib1g-dev' \
&& set -x \
&& echo "[INFO] Installing Dependencies..." \
&& apt-get -y update \
&& apt install -y $build_deps \
	curl \
	openssl \
	postgresql \
	postgresql-contrib \
	sudo \
        tmux \
	vim \
	wget \
&& echo "[INFO] Removing Build Dependencies..." \
&& apt-get autoremove --purge -y $build_deps \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN chmod +x /msfdev-entrypoint.sh \
&& /bin/bash /msfdev-entrypoint.sh

ENTRYPOINT service postgresql restart && /bin/bash
