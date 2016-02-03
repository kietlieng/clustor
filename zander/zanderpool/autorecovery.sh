#!/bin/sh

HOSTNAME=$1
PORT=$2
DBUSER=$3
DBPASS=$4
PCPDIR=$5

RESULTS_FILE='/tmp/pcp_recovery.txt'
$PCPDIR/pcp_pool_status -d 10 $HOSTNAME $PORT $DBUSER $DBPASS > $RESULTS_FILE

FOUND_NODE=''
FOUND_STATUS=''
while IFS='' read -r line || [[ -n "$line" ]]; do
    if [[ $line == "name : backend_status"* ]]
    then
      FOUND_NODE=${line:21}
      echo "$line $FOUND_NODE"
    elif [[ $line == "value:"* && $FOUND_NODE != "" ]]
    then
      FOUND_STATUS=${line:6}
      echo "$line $FOUND_STATUS"
      if [ $FOUND_STATUS -eq "3" ]
      then
        echo "found node disconnected $FOUND_NODE"
        $PCPDIR/pcp_recovery_node -d 10 $HOSTNAME $PORT $DBUSER $DBPASS $FOUND_NODE
      	break
      fi
    else
      FOUND_NODE=""
      FOUND_STATUS=""
    fi
done < $RESULTS_FILE
