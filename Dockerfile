FROM lsiobase/ubuntu:xenial

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="alex-phillips"

# packages as variables
ARG RUNTIME_PACKAGES="\
	libpq-dev \
	libssl-dev \
	libreadline-dev \
	nginx \
	nodejs \
	yarn \
	build-essential \
	git \
	zlib1g-dev"

ENV PATH="/usr/local/ruby/bin:${PATH}"
ENV RAILS_ENV="production"

RUN \
 echo "**** install build packages ****" && \
 curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
 curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
 echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
 apt-get update && \
 apt-get install -y \
 	--no-install-recommends \
	$BUILD_PACKAGES && \
 apt-get install -y \
 	--no-install-recommends \
	$RUNTIME_PACKAGES && \
 echo "**** install ruby ****" && \
 git clone https://github.com/rbenv/ruby-build.git /tmp/ruby-build && \
 PREFIX=/usr/local /tmp/ruby-build/install.sh && \
 /usr/local/bin/ruby-build 2.5.1 /usr/local/ruby && \
 /usr/local/ruby/bin/gem install bundler && \
 echo "**** install snibox ****" && \
 git clone https://github.com/snibox/snibox.git /app/snibox && \
 cd /app/snibox && \
 /usr/local/ruby/bin/bundle install && \
 echo "**** cleanup ****" && \
 apt-get purge -y --auto-remove \
	$BUILD_PACKAGES && \
 rm -rf \
	/root/.cache \
	/tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 3000
VOLUME /config
