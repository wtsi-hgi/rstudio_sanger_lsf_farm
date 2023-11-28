## Deprecated

This repo is now deprecated in favour of the [RStudio Module](https://hgi-projects.pages.internal.sanger.ac.uk/documentation/docs/how-to-guides/rstudio/).

### Rstudio server on Sanger LSF farm
  
This repository provides a bash script to start (bsub) an Rstudio server on the Sanger LSF farm, with access to `/lustre`, `/nfs` and `/software`, with optional arguments such as R version or R personal library paths.

If you are a new farm user, please consider reading first [HGI's software documentation](https://confluence.sanger.ac.uk/display/HGI/Software+on+the+Farm) to:
- set HGI's software profile in order to set your personal default R user library search path (`echo "hgi" >> ~/.softwarerc`).
- get [instructions on how to install your own libraries](https://confluence.sanger.ac.uk/display/HGI/Software+on+the+Farm#SoftwareontheFarm-CustomRLibraries) in that personal directory (you can load external libraries in Rstudio, e.g. from `/software/GROUP/USER/R/PLATFORM/VERSION`, but these need to be installed from the farm prior to starting the Rstudio server.


#### start Rstudio

Log into the Sanger farm, run the `./rstudio_bsub.sh` script to start Rstudio, and copy-paste the provided URL and password in your web browser for access.
  
All script arguments listed below are optional (the script will attempt to find reasonable default values for your Sanger user):

```
./rstudio_bsub.sh help
Usage: ./rstudio_bsub.sh [options...]

  -g, --lsf_group         (optional) LSF group (bsub -G argument)
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
  -r, --r_version         (optional) R version: must be either"4.1.0" or "4.0.3" or "3.6.1"
                          - defaults to "4.1.0"
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
                          - defaults to "bionic-R_${R_VERSION}-rstudio_1.4.sif"
                          - e.g. "bionic-R_4.1.0-rstudio_1.4.sif" or  "bionic-R_3.6.1-rstudio_1.4.sif"
  -h, --help              Display this help message
```
