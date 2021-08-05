#!/bin/bash
######
# -> Zero copy-rights. Do whatever you want with it. Have fun. 
#
# Basic log collection and stack tracing automation sequence for MF NNMi software.
# Provide nnm java module name (eg. com.hp.ov.nms.ui, com.hp.ov.nms.disco.analyzer.bn, etc.) and duration of tracing in minutes and let it work. 
# It will setup FINEST for selected module, it will tail the nnm-trace.log based on the selection, it will also capture stack traces and write them in /tmp/${modulename}
# Verify useful if you need to automate problem tracing and log collections.
# Run the script with requiered parameters, then reproduce the problem observed / wait for problem to appear, check results in the filtered output in the resulted file in /tmp/
#
# 2021, ddelsizov@gmail.com
#######

echo -n "Provide module name to be set to FINEST:  "
read -r modulename

echo -n "How long to trace? (minutes): "
read -r minutes

# Set FINEST logging for selected module

echo "** Setting FINEST logging for ${modulename} module **"
/opt/OV/support/nnmsetlogginglevel.ovpl $modulename FINEST

# Sleep a bit after command is executed

echo "** Sleeping for 10s after setting FINEST **"
sleep 10

# Set variable for eval command. I expect that proper stack traces could be captured with it.
echo "** Setting pattern matching variable for ${modulename} **"
pattern='timeout -k 5 -s SIGKILL ${minutes}m tail -n0 -F /var/opt/OV/log/nnm/nnm-trace.log | grep --line-buffered -P "(|${modulename}|^\tat |Exception|^Caused by: |\t... \d+ more)" >> /tmp/${modulename}.txt'

# Execute the tailing with eval the $pattern variable against the nnm-trace.log file with specified timeout, and graceful kill pass that period.
echo "** Running tail command with pattern-matching for grep for ${minutes} minutes **"

eval "$pattern"

echo "** Log collection done **"
echo "** Setting back INFO logging for ${modulename} module **"
/opt/OV/support/nnmsetlogginglevel.ovpl $modulename INFO

echo "** Sleeping for 10s after resetting the log levels **"
sleep 10

echo "** Script ended, check /tmp/${modulename}.txt for results **"
