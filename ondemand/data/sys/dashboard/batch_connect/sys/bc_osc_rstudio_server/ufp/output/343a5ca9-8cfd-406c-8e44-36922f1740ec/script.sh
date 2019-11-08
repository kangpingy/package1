#!/usr/bin/env bash

# Load the required environment
setup_env () {
  module purge

  # The rserver container module should set these environment variables:
  export RSTUDIO_SERVER_IMAGE="/home/software/CentOS/7.6.1810/singularityImages/rserver-launcher-centos7.simg"
  export SINGULARITY_BINDPATH="/etc,/media,/mnt,/opt,/srv,/usr,/var,/home,/nfs"
  export PATH="$PATH:/usr/lib/rstudio-server/bin"
  export SINGULARITYENV_PATH="$PATH"
 
  # SINGULARITY_BINDPATH is being used to bind all RStudio's requirements from
  # the host into the guest, and so those values may vary between sites.
  module load R/3.5.1

}
setup_env

set_loadRData () {
  export LOAD=1
  if [ $LOAD == "1" ]; then
    #Modify user-settings to load .RData on start
    echo "Setting loadRData to true"
    sed -i 's/loadRData="0"/loadRData="1"/' ${HOME}/.rstudio/monitored/user-settings/user-settings
  else
    #Modify user-settings to NOT load .RData on start
    echo "Setting loadRData to false"
    sed -i 's/loadRData="1"/loadRData="0"/' ${HOME}/.rstudio/monitored/user-settings/user-settings
  fi
}
set_loadRData

#
# Start RStudio Server
#

# PAM auth helper used by RStudio
export RSTUDIO_AUTH="${PWD}/bin/auth"

# Generate an `rsession` wrapper script
export RSESSION_WRAPPER_FILE="${PWD}/rsession.sh"
(
umask 077
sed 's/^ \{2\}//' > "${RSESSION_WRAPPER_FILE}" << EOL
  #!/usr/bin/env bash

  # Log all output from this script
  export RSESSION_LOG_FILE="${RSTUDIO_SINGULARITY_HOST_MNT}${PWD}/rsession.log"

  exec &>>"\${RSESSION_LOG_FILE}"

  # Launch the original command
  echo "Launching rsession..."
  set -x
  exec rsession --r-libs-user "${R_LIBS_USER}" "\${@}"
EOL
)
chmod 700 "${RSESSION_WRAPPER_FILE}"

# Set working directory to home directory
cd "${HOME}"

# Output debug info
module list

# set a user-specific secure cookie key
mkdir -p /tmp/rstudio-server/
chmod 777 /tmp/rstudio-server/
COOKIE_KEY_PATH=/tmp/rstudio-server/${USER}_secure-cookie-key
rm -f $COOKIE_KEY_PATH

set -x
# Launch the RStudio Server
echo "Starting up rserver..."

singularity run -B "$TMPDIR:/tmp" "$RSTUDIO_SERVER_IMAGE" \
 --www-port "${port}" \
 --auth-none 0 \
 --auth-pam-helper-path "${RSTUDIO_AUTH}" \
 --auth-encrypt-password 0 \
 --rsession-path "${RSESSION_WRAPPER_FILE}" \
 --secure-cookie-key-file $COOKIE_KEY_PATH
