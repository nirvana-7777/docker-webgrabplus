FROM lsiobase/ubuntu:xenial

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="nirvana777"

# package versions
ARG WEBGRAB_VER="2.0.0"
ARG WGUPDATE_VER="2.1.5_beta"

# environment variables.
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME /config

RUN \
 echo "**** add mono repository ****" && \
 apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
 echo "deb http://download.mono-project.com/repo/ubuntu xenial main" | tee /etc/apt/sources.list.d/mono-official.list && \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install -y \
	cron \
	libmono-system-data4.0-cil \
	libmono-system-web4.0-cil \
	libxml-dom-perl \
	php \
	php-curl \
	mono-runtime \
	unzip && \
 echo "**** install webgrabplus ****" && \
 WEBGRAB_BRANCH=${WEBGRAB_VER%.*} && \
 mkdir -p \
	/app/wg++ && \
 curl -o /tmp/wg++.tar.gz -L \
	"http://webgrabplus.com/sites/default/files/download/SW/V${WEBGRAB_VER}/WebGrabPlus_V${WEBGRAB_BRANCH}_install.tar.gz" && \
 tar xzf \
 /tmp/wg++.tar.gz -C \
	/app/wg++ --strip-components=1 && \
 WGUPDATE_BRANCH=${WGUPDATE_VER%%_*} && \
 curl -o \
 /tmp/update.tar.gz -L \
	"http://webgrabplus.com/sites/default/files/download/SW/V${WGUPDATE_BRANCH}/WebGrabPlus_V${WGUPDATE_VER}_install.tar.gz" && \
 tar xf \
 /tmp/update.tar.gz -C \
	/app/wg++/bin/ --strip-components=2 && \
 echo "**** download siteini.pack ****" && \
 curl -o \
 /tmp/ini.zip -L \
	http://webgrabplus.com/sites/default/files/download/ini/SiteIniPack_current.zip && \
 unzip -q /tmp/ini.zip -d /defaults/ini/ && \
 echo "**** install DeBaschdi EPGScripts ****" && \
 curl -o \
 /tmp/scripts.zip -L \
	https://github.com/DeBaschdi/EPGScripts/archive/master.zip && \
 unzip -q /tmp/scripts.zip -d /app/ && \
 echo "**** cleanup ****" && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add DeBaschdis files
ADD https://raw.githubusercontent.com/DeBaschdi/webgrabplus-siteinipack/master/siteini.pack/International/horizon.tv.channels.xml /defaults/ini/siteini.pack/International/
RUN chmod 644 /defaults/ini/siteini.pack/International/horizon.tv.channels.xml
ADD https://raw.githubusercontent.com/DeBaschdi/webgrabplus-siteinipack/master/siteini.pack/International/horizon.tv.ini /defaults/ini/siteini.pack/International/
RUN chmod 644 /defaults/ini/siteini.pack/International/horizon.tv.ini
ADD https://raw.githubusercontent.com/DeBaschdi/webgrabplus-siteinipack/master/siteini.pack/Germany/tvtoday.de.channels.xml /defaults/ini/siteini.pack/Germany/
RUN chmod 644 /defaults/ini/siteini.pack/Germany/tvtoday.de.channels.xml
ADD https://raw.githubusercontent.com/DeBaschdi/webgrabplus-siteinipack/master/siteini.pack/Germany/tvtoday.de.ini /defaults/ini/siteini.pack/Germany/
RUN chmod 644 /defaults/ini/siteini.pack/Germany/tvtoday.de.ini
ADD https://raw.githubusercontent.com/DeBaschdi/webgrabplus-siteinipack/master/siteini.pack/Germany/tvdigital.de.channels.xml /defaults/ini/siteini.pack/Germany/
RUN chmod 644 /defaults/ini/siteini.pack/Germany/tvdigital.de.channels.xml
ADD https://raw.githubusercontent.com/DeBaschdi/webgrabplus-siteinipack/master/siteini.pack/Germany/tvdigital.de.ini /defaults/ini/siteini.pack/Germany/
RUN chmod 644 /defaults/ini/siteini.pack/Germany/tvdigital.de.ini
ADD https://raw.githubusercontent.com/DeBaschdi/webgrabplus-siteinipack/master/siteini.pack/Germany/tvtv.de.channels.xml /defaults/ini/siteini.pack/Germany/
RUN chmod 644 /defaults/ini/siteini.pack/Germany/tvtv.de.channels.xml
ADD https://raw.githubusercontent.com/DeBaschdi/webgrabplus-siteinipack/master/siteini.pack/Germany/tvtv.de.ini /defaults/ini/siteini.pack/Germany/
RUN chmod 644 /defaults/ini/siteini.pack/Germany/tvtv.de.ini
ADD https://raw.githubusercontent.com/DeBaschdi/webgrabplus-siteinipack/master/siteini.pack/Germany/sky.de.channels.xml /defaults/ini/siteini.pack/Germany/
RUN chmod 644 /defaults/ini/siteini.pack/Germany/sky.de.channels.xml
ADD https://raw.githubusercontent.com/DeBaschdi/webgrabplus-siteinipack/master/siteini.pack/Germany/sky.de.ini /defaults/ini/siteini.pack/Germany/
RUN chmod 644 /defaults/ini/siteini.pack/Germany/sky.de.ini

RUN chmod 777 /app/EPGScripts-master/genremapper/genremapper.pl
RUN chmod -R 777 /app/EPGScripts-master/imdbmapper/
RUN sed -i -e 17c'my $path= "/app/EPGScripts-master/imdbmapper" ;' /app/EPGScripts-master/imdbmapper/imdbmapper.pl
RUN chmod 777 /app/EPGScripts-master/ratingmapper/ratingmapper.pl

# copy files
COPY root/ /

# ports and volumes
VOLUME /config /data
