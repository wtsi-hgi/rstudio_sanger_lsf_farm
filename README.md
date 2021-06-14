# rstudio_sanger_lsf_farm
  
Bash script to start (bsub) an Rstudio server on Sanger LSF farm, with access to `/lustre`, `/nfs` and `/software`.

If you are a new farm user, please consider reading first [HGI's software documentation](https://confluence.sanger.ac.uk/display/HGI/Software+on+the+Farm) to:
- set HGI's software profile in order to set your personal R user library search path
- instructions on how to install your own libraries in that personal directory.


# run the `./rstudio_bsub.sh` script to start rstudio, then copy-paste the URL and passowrd in your web browser for access.

all script arguments listed below are optional (the script will attempt to find reasonable default values for your Sanger user):parameters 

```
./rstudio_bsub.sh help
Usage: ./rstudio_bsub.sh [options...]

  -l, --lsf_group         (optional) LSF group (bsub -G argument)
                          - defaults to $LSB_DEFAULTGROUP if set, or tries to find your group(s) from lsb.users lsf config
  -m, --mem               (optional) RAM memory requested to LSF farm for Rstudio session
                          - enter a value in Mb (i.e. "15000" to get 15Gb)
                          - (passed as bsub -M argument)
                          - defaults to "15000" (i.e. 15Gb)
  -q, --queue             (optional) LSF queue (bsub -q argument)
                          - you can list available queues with command 'bqueues'
                          - you check max runtime (RUNLIMIT) of a given queue with 'bqueues -l a_queue'
                          - e.g. the "normal" queue jobs last 12 hours max (RUNLIMIT=720 minutes).
                          - defaults to "normal"
  -c, --cpus              (optional) max number of CPUs allowed for the Rstudio session
                          - Number of cpus requested to LSF farm (bsub -n argument)
                          - defaults to 2
  -d, --dir_session       (optional) path to startup/default directory for the Rstudio session
                          - do not set to your home dir $HOME as it may conflict with container settings
                          - defaults to current directory $PWD
                          - e.g. "/lustre/scratch123/hgi/projects/ukbb_scrna/pipelines/my_R_analysis"
                          - if Rstudio fails to recover a session in that directory, either:
                              1) remove its session files (i.e any .rstudio, .config, .local, .RData, and .Rhistory)
                              or 2) choose a different --dir_session directory free of any session files.
  -r, --r_version         (optional) R version: must be either "4.0.3" or "3.6.1"
                          - defaults to "4.0.3"
                          - contact HGI to add support for other R versions
  -l, --r_lib_path        (optional) path to R library path. Must be compatible with --r_version
                          - the default session .libPaths() will include: 
                              - any path set in env variable $R_LIBS_USER (if set)
                              - ISG's main libpath "/software/R-${R_VERSION}/lib/R/library"
                          - e.g. "/software/teamxxx/gn5/R/x86_64-conda_cos6-linux-gnu/4.0.3"
                          - check or edit manually with command .libPaths() from Rstudio session
  -a, --dir_singularity   (optional) Directory where singularity image is stored/cached
                          - defaults to "/software/hgi/containers"
  -i, --image_singularity filename of the singularity image (image must be in --dir_singularity)
                          - defaults to "rocker_tidyverse_${R_VERSION}.simg"
                          - e.g. "rocker_tidyverse_4.0.3.simg" or  "rocker_tidyverse_3.6.1.simg"
                          - (these are built from https://hub.docker.com/r/rocker/tidyverse)
  -h, --help              Display this help message
```