#!/bin/bash

SCRIPT=`realpath $0`
SCRIPT_PATH=`dirname $SCRIPT`
DATA_PATH="$SCRIPT_PATH/data"

mkdir -p $DATA_PATH

touch $DATA_PATH/minute
touch $DATA_PATH/minute-live
touch $DATA_PATH/minute-100
touch $DATA_PATH/hour
touch $DATA_PATH/hour-live
touch $DATA_PATH/hour-100
touch $DATA_PATH/day
touch $DATA_PATH/day-live
touch $DATA_PATH/day-100
touch $DATA_PATH/month
touch $DATA_PATH/month-live
touch $DATA_PATH/month-100
touch $DATA_PATH/down
touch $DATA_PATH/up
