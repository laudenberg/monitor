#!/bin/bash

SCRIPT=`realpath $0`
SCRIPT_PATH=`dirname $SCRIPT`
DATA_PATH="$SCRIPT_PATH/data"

TEMPFILE=`tempfile`

ping() {
    CURL=`curl -L -s -m 10 -o /dev/null -w "%{http_code} %{time_total}" $2`

    if [ $? -eq 0 ]; then
      IFS=' ' read -ra ADDR <<< "$CURL"

      if [ "${ADDR[0]}" -eq 200 ]; then
        echo $1 ${ADDR[1]}
      else
        echo $1 11
      fi
    else
      echo $1 12
    fi
}

LINE=""
PING="1"


while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -timestamp)

    LINE="$LINE `date +"%s"`"
    ;;

    -load)

    LINE="$LINE `cat /proc/loadavg | awk '{print $1}'`"

    ;;
    -mem)

    LINE="$LINE `free | grep Mem | awk '{used = ($3) * 100 / $2; print int(used)}'`"

    ;;
    -disk)

    LINE="$LINE `df $2 | tail -n 1 | awk '{print $5}' | sed 's/%//'`"
    shift

    ;;
    -down)

    DOWN_CURRENT=`cat /proc/net/dev | grep $2 | awk '{print $2}'`
    DOWN_LAST=`< $DATA_PATH/down`
    DOWN_DELTA=$(( DOWN_CURRENT - DOWN_LAST ))
    if [ $DOWN_DELTA -lt 0 ]; then DOWN_DELTA=0; fi

    echo $DOWN_CURRENT > "$DATA_PATH/down"

    LINE="$LINE $DOWN_DELTA"
    shift

    ;;
    -up)

    UP_CURRENT=`cat /proc/net/dev | grep $2 | awk '{print $10}'`
    UP_LAST=`< $DATA_PATH/up`
    UP_DELTA=$(( UP_CURRENT - UP_LAST ))
    if [ $UP_DELTA -lt 0 ]; then UP_DELTA=0; fi

    echo $UP_CURRENT > "$DATA_PATH/up"

    LINE="$LINE $UP_DELTA"
    shift

    ;;
    -ping)

    PING=$((PING + 1))
    LINE="$LINE PING$PING"
    ping $PING $2 >> $TEMPFILE &
    shift

    ;;
    -alerts)
    ALERT=$2
    shift

    ;;
    -alertmailto)
    ALERTMAILTO=$2
    shift

    ;;
    -config)
    CONFIG=$2
    shift

    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

wait

while read line; do
  sedexp=`echo $line | sed -e 's/^/s\/PING/' -e 's/ /\//' -e 's/$/\//'`
  LINE=`echo $LINE | sed -e "$sedexp"`
done < $TEMPFILE

rm $TEMPFILE

echo $LINE > "$DATA_PATH/minute-live"
$SCRIPT_PATH/average.sh minute 60 100 > "$DATA_PATH/hour-live"
$SCRIPT_PATH/average.sh hour 24 100 > "$DATA_PATH/day-live"
$SCRIPT_PATH/average.sh day 30 100 > "$DATA_PATH/month-live"
echo $LINE >> "$DATA_PATH/minute-100"
$SCRIPT_PATH/truncate.sh minute-100 100
echo $LINE >> "$DATA_PATH/minute"

echo $LINE | $SCRIPT_PATH/check-alert.sh "$ALERT" "$CONFIG"
