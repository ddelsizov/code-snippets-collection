#!/bin/bash
######
# Log collecting tool for MF NNMi Software.
# This is configured specifically to set finest tracing for northbound.im which is responsible for NNMi - OMi event integration and other 3rd party software.
# It will collect specific entries and stack traces in a new file for ease of tracing and diagnosing a problem -> /tmp/nortbound.txt
#######

# Cleanup from previous runs if any
rm -f /tmp/northbound.txt

# Set neccessery FINEST levels

echo "** Setting FINEST logging for Northbound module **"
/opt/OV/support/nnmsetlogginglevel.ovpl com.hp.ov.nnm.northbound.im FINEST

# Sleep a bit after command is executed

echo "** Sleeping for 20s **"
sleep 20

# Set variable for pattern matching in grep
echo "** Setting pattern matching variable **"

pattern='timeout -k 5 -s SIGKILL 10m tail -n0 -F /var/opt/OV/log/nnm/nnm-trace.log | grep --line-buffered -P "(|com.hp.ov.nms.northbound|com.hp.ov.nms.events|^\tat |Exception|^Caused by: |\t... \d+ more)" >> /tmp/northbound.txt'

# Run tail against the log file with 10 minutes timeout, and graceful kill pass that.

echo "** Running tail command with pattern-matching for grep for 10 minutes **"

eval "$pattern"

echo "** Log collection done **"

echo "** Sleeping for 20s before resetting the log level **"
sleep 20

# Reset log level back to normal

echo "** Setting back INFO logging for Northbound module **"
/opt/OV/support/nnmsetlogginglevel.ovpl com.hp.ov.nnm.northbound.im INFO

echo "** Script ended, check /tmp/northbound.txt for results **"