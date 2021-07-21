#!/usr/bin/env bash

set -eu

declare VERSIONS="versions.yml"
declare IMG_FORMAT="${1-sif}"

for R_VERSION in $(yq eval ".R[].version" "${VERSIONS}"); do
  for RSTUDIO_VERSION in $(yq eval ".RStudio[].version" "${VERSIONS}"); do
    echo "bionic_R-${R_VERSION}_rstudio-${RSTUDIO_VERSION}.${IMG_FORMAT}"
  done
done
