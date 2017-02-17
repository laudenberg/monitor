#!/bin/bash

SCRIPT=`realpath $0`
SCRIPT_PATH=`dirname $SCRIPT`
DATA_PATH="$SCRIPT_PATH/data"

ARGUMENTS=`$SCRIPT_PATH/arguments-from-config.rb $1`

if [ $# -lt 1 ]; then
  echo "please specify config.json"
  exit -1
fi

echo "\
0 0 1 * * /bin/bash -l -c \"$SCRIPT_PATH/average-and-truncate.sh day 30 month 100\"
0 0 * * * /bin/bash -l -c \"$SCRIPT_PATH/average-and-truncate.sh hour 24 day 100\"
0 * * * * /bin/bash -l -c \"$SCRIPT_PATH/average-and-truncate.sh minute 60 hour 100\"
* * * * * /bin/bash -l -c \"$SCRIPT_PATH/collect.sh $ARGUMENTS\"
"