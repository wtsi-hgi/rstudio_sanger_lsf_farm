#!/usr/bin/env bash

tag=4.0.3 # pulled 3.6.1 and 4.0.3
dockerhub=docker://rocker/tidyverse:$tag
image=rocker_tidyverse_${tag}.simg

mkdir -p cache_dir
SINGULARITY_CACHEDIR=$PWD/cache_dir

mkdir -p tmp_dir
TMPDIR=$PWD/tmp_dir

# rm -f $image || true
echo image $image
singularity pull --name $image $dockerhub

