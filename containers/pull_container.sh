#!/usr/bin/env bash

tag=4.0.3 # pulled 3.6.1, 4.0.3 and 4.1.0
dockerhub=docker://rocker/tidyverse:$tag
image=rocker_tidyverse_${tag}.simg

mkdir -p cache_dir
export SINGULARITY_CACHEDIR=$PWD/cache_dir

mkdir -p tmp_dir
export TMPDIR=$PWD/tmp_dir

# rm -f $image || true
echo image $image
singularity pull --name $image $dockerhub

# manually move to /software/hgi/containers/ :
# e.g.
# mercury@farm5-head1 ~$ mv /lustre/scratch123/hgi/projects/ukbb_scrna/pipelines/singularity_images/rocker_tidyverse_4.1.0.simg /software/hgi/containers/
