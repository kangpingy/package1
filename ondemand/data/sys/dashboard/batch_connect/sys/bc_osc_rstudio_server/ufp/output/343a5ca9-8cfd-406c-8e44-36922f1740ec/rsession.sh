#!/usr/bin/env bash

# Log all output from this script
export RSESSION_LOG_FILE="/home/kangpiny/ondemand/data/sys/dashboard/batch_connect/sys/bc_osc_rstudio_server/ufp/output/343a5ca9-8cfd-406c-8e44-36922f1740ec/rsession.log"

exec &>>"${RSESSION_LOG_FILE}"

# Launch the original command
echo "Launching rsession..."
set -x
exec rsession --r-libs-user "" "${@}"
