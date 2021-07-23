# RStudio Server on LSF

Submit an RStudio Server session to an LSF cluster.

This is optimised for the Sanger Institute farm, configured with the
Sanger web proxies, access to `/lustre`, `/nfs` and `/software`, and
further optional arguments (such as R version or R personal library
paths).

If you are a new farm user, please consider reading
[HGI's software documentation](https://confluence.sanger.ac.uk/display/HGI/Software+on+the+Farm).
This covers:

* Using HGI's software profile in order to set your personal R library
  search path (`echo "hgi" >> ~/.softwarerc`).

* [Instructions on how to install your own libraries](https://confluence.sanger.ac.uk/display/HGI/Software+on+the+Farm#SoftwareontheFarm-CustomRLibraries)
  in that personal directory. These can be used in an RStudio Server
  session, but must be installed from the farm first.

## Usage

From an LSF machine (e.g., a Sanger farm head node), run:

    bsub-rstudio

This will submit the RStudio Server job to the LSF cluster with the
given arguments, if any, following its output automatically. Note that
the job may not execute immediately and can take some time to start;
please be patient. When the job starts, the server will start and you
will be provided with the URL, username and password, which you can use
in your browser to access the RStudio Server session.

All script arguments -- listed below -- are optional; the script will
attempt to find reasonable default values for your Sanger user:

```
Usage: bsub-rstudio [OPTIONS]

LSF Options:

  -G  LSF Group
      * Corresponds to bsub's -G
      * Default: $LSB_DEFAULTGROUP if set, otherwise tries to find your
        groups from the LSF configuration and chooses at random

  -M  Memory (in MiB) for the RStudio Server session
      * Corresponds with bsub's -M
      * Default: 15000

  -n  Number of CPUs for the RStudio Server session
      * Corresponds with bsub's -n
      * Default: 2

  -q  LSF queue
      * Corresponds with bsub's -q
      * Default: normal

R Options:

  -R  R version
      * Defined in configuration (currently 3.6, 4.0 and 4.1)
      * Contact HGI to add support for other R versions
      * Default: 4.1 (defined in configuration)

  -d  Session directory
      * Do not set to your home directory, as this may cause conflicts
      * If RStudio Server fails to recover the session, either:
        1. Remove its session files (i.e., any .rstudio, .config,
           .local, .RData and .Rhistory files)
        2. Choose a different directory, free of any session files
      * Default: Current working directory

  -l  R library search paths
      * Corresponds to R_LIBS_USER environment variable
      * The library paths must be compatible with the chosen R version
      * Default: Current R_LIBS_USER and host R library path (defined in
        configuration)

Miscellaneous Options:

  -C  Configuration JSON file
      * Default: config.json in installation directory
```

### Killing your RStudio Server Job

Once you have finished your RStudio Server session, the following
command will attempt to automatically identify its LSF job and kill it:

    bkill-rstudio

If you have no, or multiple RStudio Server jobs running, then it will
refuse to comply. In such cases, manual clean up will be required.

If you only wish to obtain the LSF job ID for your RStudio Server
session, you can set the `NO_KILL` environment variable:

    NO_KILL=1 bkill-rstudio
