#!/usr/bin/env bash
#
# Lock down admin users
#  - disable the default cassandra user
#  - create users for admin, opscenter, zonar
#  - use passwords supplied 
#
admin_user=${1?"Missing admin id arg 1"}
admin_pw=${2?"Missing admin pw arg 2"}
opscenter_user=${3?"Missing opscenter id arg 3"}
opscenter_pw=${4?"Missing opscenter pw arg 4"}
zonar_user=${5?"Missing zonar id arg 5"}
zonar_pw=${6?"Missing zonar pw arg 6"}

CQLSH_CMD=$(which cqlsh)
if [ $? -ne 0 ];then
    echo "ERROR - could not find cqlsh"
    exit 1
fi

echo "Found cqlsh at $CQLSH_CMD"
#
# alter keyspace system_auth with replication = { 'class' : 'NetworkTopologyStrategy', 'dc0' : 3 }
#
$CQLSH_CMD -u cassandra -p cassandra -e "alter keyspace system_auth with replication = { 'class' : 'NetworkTopologyStrategy', 'dc0' : 3 };"
if [ $? -ne 0 ];then
    echo "ERROR: Unable to alter replication"
    exit 2
fi
#
# Need to "repair" all the nodes to propogate the replication. (???)
#
#======== new admin and disable old =================
# 
# create user king with password 'royal' superuser;
$CQLSH_CMD -u cassandra -p cassandra -e "create user $admin_user with password '$admin_pw' superuser;"
if [ $? -ne 0 ];then
    echo "ERROR: Unable to create new superuser"
    exit 3
fi
echo "Added user $admin_user"
# 
# alter user cassandra with password 'randomcrap093284059507!!!' nosupseruser;
# 
# TODO: RANDON PASSWORD NEEDED
$CQLSH_CMD -u $admin_user -p $admin_pw -e "alter user cassandra with password 'randomcrap093284059507!!!' nosupseruser;"
if [ $? -ne 0 ];then
    echo "ERROR: Unable to alter default superuser"
    exit 3
fi
# 
# create user opscenter with password 'view0psCenter!!';
$CQLSH_CMD -u $admin_user -p $admin_pw -e "create user $opscenter_user with password '$opscenter_pw';"
if [ $? -ne 0 ];then
    echo "ERROR: Unable to create new opscenter user"
    exit 3
fi
echo "Added user $opscenter_user"
#
# grant all on keyspace "OpsCenter" to opscenter;
$CQLSH_CMD -u $admin_user -p $admin_pw -e "grant all on keyspace "OpsCenter" to $opscenter_user;"
if [ $? -ne 0 ];then
    echo "ERROR: Unable to set opscenter permissions"
    exit 3
fi
# 
# create user zonar with password 'letM3see!?';
$CQLSH_CMD -u $admin_user -p $admin_pw -e "create user $zonar_user with password '$zonar_pw';"
if [ $? -ne 0 ];then
    echo "ERROR: Unable to create new zonar user"
    exit 3
fi
# grant all on keyspace zonar to zonar;
$CQLSH_CMD -u $admin_user -p $admin_pw -e "grant all on keyspace zonar to $zonar_user;"
if [ $? -ne 0 ];then
    echo "ERROR: Unable to set zonar permissions"
    exit 3
fi
#
# list users;
#
$CQLSH_CMD -u $admin_user -p $admin_pw -e "list users;"
if [ $? -ne 0 ];then
    echo "ERROR: Unable to list users"
    exit 3
fi
# list all permissions;
$CQLSH_CMD -u $admin_user -p $admin_pw -e "list all permissions;"
if [ $? -ne 0 ];then
    echo "ERROR: Unable to list permissions"
    exit 3
fi
#
exit 0
