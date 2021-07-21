# Singularity Containers

The Singularity containers for R and RStudio Server can be built from
the recipes generated herein. These containers are based on Ubuntu
Bionic, matching the [current] distribution of Sanger farm machines --
as opposed to the [Rocker Project](https://www.rocker-project.org)
images which, at time of writing, are Focal-based -- to maintain ABI
compatibility, allowing shared objects from the host to be bind mounted.

## Usage

These images can be made on any Debian-like host on which you have
`root` and the following dependencies installed:

* [GNU Make](https://www.gnu.org/software/make)
* [GNU grep](https://www.gnu.org/software/grep)
* [Singularity](https://github.com/sylabs/singularity)
* [debootstrap](https://wiki.debian.org/Debootstrap)
* [yq](https://mikefarah.gitbook.io/yq)

To build the suite of images, simply run:

    make [IMG_FORMAT=sif]

By default, `.sif` images are created. This can be changed by setting
the `IMG_FORMAT` variable.

### Version Suite

The suite of images is defined in `versions.yml`, as the cross-product
of R and RStudio Server versions.

## Container Usage

The default run script for the containers is `rserver`, which starts an
RStudio Server session with the given arguments. At a minimum, the
following container directories need to be bind mounted (read-writable)
from the host:

* `/var/lib/rstudio-server`
* `/var/run/rstudio-server`
* `/tmp/rstudio-server`

A simple PAM helper script, modelled on that by the Rocker Project, is
included (`/usr/local/bin/pam-helper`) to allow simple authentication
through the `USER` and `PASSWORD` environment variables; these can be
injected from the host by exporting `SINGULARITYENV_USER` and
`SINGULARITYENV_PASSWORD`, respectively.
