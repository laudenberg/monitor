#!/bin/bash

SCRIPT=`realpath $0`
SCRIPT_PATH=`dirname $SCRIPT`
DATA_PATH="$SCRIPT_PATH/data"

read line

CNT=1

for i in $line; do
  declare value$CNT=$i;
  CNT=$(( CNT + 1 ))
done

CNT=1

for i in $1; do

  if [ "$i" != "NULL" ]; then
    CUR=value$CNT
    
    if (( $(echo "${!CUR} $i" | awk '{print ($1 > $2)}') )); then
      $SCRIPT_PATH/alert.rb "$CNT" "${!CUR}" "$2"
    fi

  fi

  CNT=$(( CNT + 1 ))
done
