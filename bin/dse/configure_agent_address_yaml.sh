#!/usr/bin/env bash

node_ip=$1
node_broadcast_ip=$2
opscenter_ip=$3
# security
cass_user=${4:-cassandra}
cass_pass=${5:-cassandra}
mcass_user=${6:-cassandra}
mcass_pass=${7:-cassandra}

# looks like the agent creates an empty /var/lib/datastax-agent/conf/address.yaml when it starts for the first time
# given that, we're not going to worry about backing it up

file=/var/lib/datastax-agent/conf/address.yaml

cat <</EOF > $file
stomp_interface: $opscenter_ip
agent_rpc_interface: $node_ip
agent_rpc_broadcast_address: $node_broadcast_ip
cassandra_user: $cass_user
cassandra_pass: $cass_pass
monitored_cassandra_user: $mcass_user
monitored_cassandra_pass: $mcass_pass
/EOF

chown cassandra $file
chgrp cassandra $file
