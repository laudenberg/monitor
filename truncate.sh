#!/bin/bash

SCRIPT=`realpath $0`
SCRIPT_PATH=`dirname $SCRIPT`
DATA_PATH="$SCRIPT_PATH/data"

TEMPFILE=`tempfile`

tail -n $2 $DATA_PATH/$1 > $TEMPFILE
mv $TEMPFILE $DATA_PATH/$1
