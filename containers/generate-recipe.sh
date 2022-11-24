#!/usr/bin/env bash

# Copyright (c) 2021 Genome Research Ltd.
#
# Author: Christopher Harrison <ch12@sanger.ac.uk>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at
# your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

set -eu

get_metadata() {
  local software="$1"
  local name="$2"
  local attribute="$3"

  yq eval ".${software}[] | select(.name == \"${name}\").${attribute}" versions.yml
}

declare TARGET="$1"

declare R_ID="$(echo "${TARGET}" | grep -Po "(?<=-R_).+(?=-)")"
declare R_VERSION="$(get_metadata R "${R_ID}" version)"
declare R_SOURCE="$(get_metadata R "${R_ID}" source)"

declare RSTUDIO_ID="$(echo "${TARGET}" | grep -Po "(?<=-rstudio_).+$")"
declare RSTUDIO_VERSION="$(get_metadata RStudio "${RSTUDIO_ID}" version)"
declare RSTUDIO_SOURCE="$(get_metadata RStudio "${RSTUDIO_ID}" source)"

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
  apt install -y --no-install-recommends \\
    git wget \\
    make g++ \\
    r-base-core=${R_VERSION} \\
    r-base-html=${R_VERSION} \\
    r-doc-html=${R_VERSION} \\
    /rstudio.deb

  curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
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
