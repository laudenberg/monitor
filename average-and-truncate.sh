#!/bin/bash

SCRIPT=`realpath $0`
SCRIPT_PATH=`dirname $SCRIPT`
DATA_PATH="$SCRIPT_PATH/data"

DATA=`$SCRIPT_PATH/average.sh $1 $2 $4`
echo $DATA >> $DATA_PATH/$3
echo $DATA >> $DATA_PATH/$3-$4
$SCRIPT_PATH/truncate.sh $3 $4
