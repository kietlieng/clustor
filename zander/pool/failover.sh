#!/bin/sh -x
# Execute command by failover.
# special values:  %d = node id
#                  %h = host name
#                  %p = port number
#                  %D = database cluster path
#                  %m = new master node id
#                  %M = old master node id
#                  %H = new master node host name
#                  %P = old primary node id
#                  %% = '%' character
failed_node_id=$1
new_master_host_name=$2
old_primary_node_id=$3
trigger=/tmp/postgresql.trigger.5432

if [ $failed_node_id = $old_primary_node_id ];then	# master failed
    ssh -T postgres@$new_master_host_name touch $trigger	# let standby take over
    echo "ssh -T postgres@$new_master_host_name touch $trigger" >> /tmp/failover.output
fi
