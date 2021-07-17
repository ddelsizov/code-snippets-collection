#!/bin/bash

# -w used to write out special variables
# --fail uses exit code for better scripting
# -s silent, 
# -o output,

options='--fail --connect-timeout 3 --retry 0 -s -o /dev/null -w %{http_code}'

echo "*************************"
echo "Pulling response from page"
echo "*************************"

page="https://www.google.com"
outstr=$(curl $options $page)
retVal=$?
[[ $retVal -eq 0 ]] || { echo "ERROR should have been able to pull $page, retVal=$retVal, code=$outstr"; exit 4; }

echo "OK pulling from $page successful, retVal=$retVal, code=$outstr"