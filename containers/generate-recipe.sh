#!/usr/bin/env bash

set -eu

get_source() {
  local software="$1"
  local version="$2"

  yq eval ".${software}[] | select(.version == \"${version}\").source" versions.yml
}

declare TARGET="$1"

declare R_VERSION="$(echo "${TARGET}" | grep -Po "(?<=_R-).+(?=_rstudio)")"
declare R_SOURCE="$(get_source R "${R_VERSION}")"

declare RSTUDIO_VERSION="$(echo "${TARGET}" | grep -Po "(?<=_rstudio-).+$")"
declare RSTUDIO_SOURCE="$(get_source RStudio "${RSTUDIO_VERSION}")"

cat <<RECIPE
Bootstrap: debootstrap
OSVersion: bionic
MirrorURL: http://archive.ubuntu.com/ubuntu
Include: ca-certificates curl gnupg locales language-pack-en

%help
  Containerised RStudio Server

%labels
  Maintainer  Christopher Harrison <ch12@sanger.ac.uk>
  R           ${R_VERSION}
  RStudio     ${RSTUDIO_VERSION}

%post
  export DEBIAN_FRONTEND=noninteractive

  cat >/etc/apt/sources.list <<-EOF
	deb http://archive.ubuntu.com/ubuntu bionic main universe
	deb ${R_SOURCE}
	EOF

  update-locale LANG=en_GB.UTF-8 LC_MESSAGES=POSIX

  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
  apt update

  curl -o /rstudio.deb ${RSTUDIO_SOURCE}
  apt install -y r-base=${R_VERSION} /rstudio.deb

  rm /rstudio.deb
  apt autoremove
  apt clean

  cat >/etc/rstudio/database.conf <<-EOF
	provider=sqlite
	directory=/var/lib/rstudio-server
	EOF

  cat >/usr/local/bin/pam-helper <<-'EOF'
	#!/bin/sh
	set -o nounset
	IFS='' read -r password
	[ "\${USER}" = "\$1" ] && [ "\${PASSWORD}" = "\${password}" ]
	EOF
  chmod 0755 /usr/local/bin/pam-helper

  unset DEBIAN_FRONTEND

%runscript
  exec /usr/lib/rstudio-server/bin/rserver "\$@"
RECIPE
