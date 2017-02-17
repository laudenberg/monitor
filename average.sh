#!/bin/bash

SCRIPT=`realpath $0`
SCRIPT_PATH=`dirname $SCRIPT`
DATA_PATH="$SCRIPT_PATH/data"

echo -n "`date +%s` "

(tail -n $2 $DATA_PATH/$1-$3; cat $DATA_PATH/$1-live) | uniq | awk '
  {
    for (i = 2; i <= NF; i++) {
      acc[i] += $i;
      cnt[i] += 1;

      if (i > max)
        max = i;
    }

  }

  END {
    line = "";
    
    for (i = 2; i <= max; i++) {
      line = line (acc[i] / cnt[i]) " ";
    }

    print line;
  }
'