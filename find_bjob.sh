#!/usr/bin/env bash
set -e

UNIX_USER=$(id -un)

bjobs -w | grep "bsub rstudio user $UNIX_USER"

# bjobs -w | grep "bsub rstudio user $UNIX_USER" | cut -f1 -d" " | xargs bkill
