#!/usr/bin/env bash
set -e # exit when any command fails

# HGI software documentation:
#  - https://confluence.sanger.ac.uk/display/HGI/Software+on+the+Farm

#########################
# The command line help #
#########################
display_help() {
    echo "Usage: $0 [options...]" >&2
    echo
    echo "  -l, --lsf_group         (optional) LSF group (bsub -G argument)"
    echo "                          - defaults to \$LSB_DEFAULTGROUP if set, or tries to find your group(s) from lsb.users lsf config"
    echo "  -m, --mem               (optional) RAM memory requested to LSF farm for Rstudio session"
    echo "                          - enter a value in Mb (i.e. \"15000\" to get 15Gb)"
    echo "                          - (passed as bsub -M argument)"
    echo "                          - defaults to \"15000\" (i.e. 15Gb)"
    echo "  -q, --queue             (optional) LSF queue (bsub -q argument)"
    echo "                          - you can list available queues with command 'bqueues'"
    echo "                          - you check max runtime (RUNLIMIT) of a given queue with 'bqueues -l a_queue'"
    echo "                          - e.g. the \"normal\" queue jobs last 12 hours max (RUNLIMIT=720 minutes)."
    echo "                          - defaults to \"normal\""
    echo "  -c, --cpus              (optional) max number of CPUs allowed for the Rstudio session"
    echo "                          - Number of cpus requested to LSF farm (bsub -n argument)"
    echo "                          - defaults to 2"
    echo "  -d, --dir_session       (optional) path to startup/default directory for the Rstudio session"
    echo "                          - do not set to your home dir \$HOME as it may conflict with container settings"
    echo "                          - defaults to current directory \$PWD"
    echo "                          - e.g. \"/lustre/scratch123/hgi/projects/ukbb_scrna/pipelines/my_R_analysis\""
    echo "                          - if Rstudio fails to recover a session in that directory, either:" 
    echo "                              1) remove its session files (i.e any .rstudio, .config, .local, .RData, and .Rhistory)"
    echo "                              or 2) choose a different --dir_session directory free of any session files."
    echo "  -r, --r_version         (optional) R version: must be either \"4.0.3\" or \"3.6.1\""
    echo "                          - defaults to \"4.0.3\""
    echo "                          - contact HGI to add support for other R versions"
    echo "  -l, --r_lib_path        (optional) path to R library path. Must be compatible with --r_version" 
    echo "                          - the default session .libPaths() will include: "
    echo "                              - any path set in env variable \$R_LIBS_USER (if set)"
    echo "                              - ISG's main libpath \"/software/R-\${R_VERSION}/lib/R/library\""
    echo "                          - e.g. \"/software/teamxxx/gn5/R/x86_64-conda_cos6-linux-gnu/4.0.3\""
    echo "                          - check or edit manually with command .libPaths() from Rstudio session"
    echo "  -a, --dir_singularity   (optional) Directory where singularity image is stored/cached"
    echo "                          - defaults to \"/software/hgi/containers\""
    echo "  -i, --image_singularity filename of the singularity image (image must be in --dir_singularity)"
    echo "                          - defaults to \"rocker_tidyverse_\${R_VERSION}.simg\""
    echo "                          - e.g. \"rocker_tidyverse_4.0.3.simg\" or  \"rocker_tidyverse_3.6.1.simg\""
    echo "                          - (these are built from https://hub.docker.com/r/rocker/tidyverse)"
    echo "  -h, --help              Display this help message "
    echo
    exit 1
}

################################
# process CLI arguments        #
################################
while :
do
    case "$1" in
      -h | --help)
          display_help
          exit 1 
          ;;
      -l | --lsf_group)
          export LSF_GROUP=$2
          shift 2
          ;;
      -m | --mem)
          export MEM=$2
          shift 2
          ;;
      -q | --queue)
          export QUEUE=$2
          shift 2
          ;;
      -c | --cpus)
	  export N_CPUS=$2 # must match number of CPUs requested by bsub
          shift 2
          ;;
      -r | --r_version)
          export R_VERSION=$2  # as of June 9th 2021, 4.0.3 and 3.6.1 were pulled from dockerhub to /software/hgi/containers/
          shift 2
          ;;
      -d | --dir_session)
	  export SESSION_DIRECTORY=$2
          shift 2
          ;;
      -a | --dir_singularity)
	  export SINGULARITY_CACHE_DIR=$2 #  /software/hgi/containers
          shift 2
          ;;
      -i | --image_singularity)
	  export IMAGE_SINGULARITY=$2 
          shift 2
          ;;
      --) # End of all options
          shift
          break
          ;;
      -*)
          echo "Error: Unknown option: $1" >&2
          display_help
          exit 1 
          ;;
      *)  # No more options
          break
          ;;
    esac
done

###################### 
# Check if parameter #
# is set to execute #
######################
case "$1" in
  help)
    display_help
    ;;
  *)
    [ -e rstudio_session.log ] && rm -- rstudio_session.log

    # set default values for bsub:
    export MEM="${MEM:-15000}"
    export N_CPUS="${N_CPUS:-2}"
    export QUEUE="${QUEUE:-normal}"


    # find LSF group for bsub -G argument
    # first, check available lsf groups from lsf config file:
    LSF_CONF=/usr/local/lsf/conf/lsbatch/farm5/configdir/lsb.users
    UNIX_USER=$(id -un)

    USER_GROUPS=$(cat $LSF_CONF | grep $UNIX_USER | grep default | grep -v '^#') || \
	(echo "Error: the user $UNIX_USER does not seem to be any LSF group as listed in ${LSF_CONF} . Contact HGI (hgi@sanger.ac.usk)" && exit 1)
    
    # assign lsf group
    if test -z "$LSF_GROUP" 
      then
        echo "\$LSF_GROUP is empty"
        if test -z "$LSB_DEFAULTGROUP" 
          then
            echo "\$LSB_DEFAULTGROUP is empty"
	    # because LSF_GROUP not specified, and $LSB_DEFAULTGROUP is empty, assign random group from lsf conf file  
	    export LSF_GROUP=$(cat $LSF_CONF | grep $UNIX_USER | grep default | grep -v '^#' | head -n 1 |cut -f1 -d " ")
	    echo "assigning random lsf group for user $UNIX_USER from lsf config file $LSF_CONF : $LSF_GROUP"
          else
            echo "\$LSB_DEFAULTGROUP not empty, therefore setting \$LSF_GROUP to \$LSB_DEFAULTGROUP"
	    export LSF_GROUP=$LSB_DEFAULTGROUP
        fi
    fi
    echo LSF_GROUP is $LSF_GROUP
    
    # check lsf group exists and matches user
    USER_GROUPS=$(cat $LSF_CONF | grep $UNIX_USER | grep -v '^#' | grep $LSF_GROUP) || \
	(echo "Error: the user $UNIX_USER does not seem to be in LSF group $LSF_GROUP according to list ${LSF_CONF} . Contact HGI (hgi@sanger.ac.usk)" && exit 1)
    


    printf "\n***bsub arguments***"
    printf "\n  \$MEM memory requested: $MEM Mb"
    printf "\n  \$N_CPUS N cpus requested: $N_CPUS"
    printf "\n  \$QUEUE bqueue requested: $QUEUE"
    printf "\n  \$LSF_GROUP requested: $LSF_GROUP"
    printf "\n****** \n"
    
    # set default values for start_rstudio_server.sh script:
    export R_VERSION="${R_VERSION:-4.0.3}"  # as of June 9th 2021, 4.0.3 and 3.6.1 were pulled from dockerhub to /software/hgi/containers/
    export SESSION_DIRECTORY="${SESSION_DIRECTORY:-$PWD}"
    export SINGULARITY_CACHE_DIR="${SINGULARITY_CACHE_DIR:-/software/hgi/containers}" #  /software/hgi/containers
    export IMAGE_SINGULARITY="${IMAGE_SINGULARITY:-rocker_tidyverse_$R_VERSION.simg}" 

    
    printf "\nstarting bsub... \n"
    bsub -G $LSF_GROUP \
	 -R "select[model==Intel_Platinum, mem>$MEM] rusage[tmp=5000, mem=$MEM] span[hosts=1]" \
	 -M $MEM -n $N_CPUS \
	 -o rstudio_session.log \
	 -e rstudio_session.log \
	 -q $QUEUE \
	 -J "bsub rstudio user $UNIX_USER" \
	 bash rstudio_node_rserver.sh \
	 --r_version $R_VERSION \
	 --cpus $N_CPUS \
	 --dir_session $SESSION_DIRECTORY \
	 --dir_singularity $SINGULARITY_CACHE_DIR \
	 --image_singularity $IMAGE_SINGULARITY \
	 > rstudio_session.log
    
    echo waiting for LSF job to start... >> rstudio_session.log
    echo finished bsub
    echo see file rstudio_session.log for Rstudio IP address and port
    tail -f rstudio_session.log

    exit 1
    ;;
esac
