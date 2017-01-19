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
NODETOOL_CMD=$(which nodetool)
if [ $? -ne 0 ];then
    echo "ERROR - could not find nodetool"
    exit 1
fi

echo "Found nodetool at $NODETOOL_CMD"
$NODETOOL_CMD status
if [ $? -ne 0 ];then
    echo "ERROR - could not nodetool status"
    exit 1
fi

#---------------------------------------------
# determine if these changes have already occured...each node will attempt.   Check for ability to login via default superuser.  If that fails check for new superuser.  IF that fails...then we have a problem.
echo "Checking if user updates have been performed."
$CQLSH_CMD -u cassandra -p cassandra -e "list users;"
if [ $? -ne 0 ];then
    echo "WARN: Check for user update.  May have been done by another node already.  This is OK."
    $CQLSH_CMD -u $admin_user -p $admin_pw -e "list users;"
    if [ $? -ne 0 ];then
        echo "ERROR: Check for user update.  Can not access with either superuser."
        exit 2
    fi
    echo "Changes appear to be already performed.  Running node repair to clean up (just in case)."
    $NODETOOL_CMD repair -local
    if [ $? -ne 0 ];then
        echo "ERROR - could not nodetool repair -local this node"
    fi
    echo "Exiting script"
    exit 0
fi
#---------------------------------------------
# alter keyspace system_auth with replication = { 'class' : 'NetworkTopologyStrategy', 'dc0' : 3 }
#
echo "Altering Replication"
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
echo "Changing Admin"
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
echo "Disable Default Admin"
$CQLSH_CMD -u $admin_user -p $admin_pw -e "alter user cassandra with password 'randomcrap093284059507!!!' nosuperuser;"
if [ $? -ne 0 ];then
    echo "ERROR: Unable to alter default superuser"
    exit 3
fi
# 
# create user opscenter with password 'view0psCenter!!';
echo "Creating opscenter user"
$CQLSH_CMD -u $admin_user -p $admin_pw -e "create user $opscenter_user with password '$opscenter_pw';"
if [ $? -ne 0 ];then
    echo "ERROR: Unable to create new opscenter user"
    exit 3
fi
echo "Added user $opscenter_user"
#
# grant all on keyspace "OpsCenter" to opscenter;
#echo "granting opscenter"
#$CQLSH_CMD -u $admin_user -p $admin_pw -e "grant all on keyspace \"OpsCenter\" to $opscenter_user;"
#if [ $? -ne 0 ];then
#    echo "ERROR: Unable to set opscenter permissions"
#    exit 3
#fi
# 
# create user zonar with password 'letM3see!?';
echo "Creating zonar user"
$CQLSH_CMD -u $admin_user -p $admin_pw -e "create user $zonar_user with password '$zonar_pw';"
if [ $? -ne 0 ];then
    echo "ERROR: Unable to create new zonar user"
    exit 3
fi
# grant all on keyspace zonar to zonar;
#echo "granting zonar"
#$CQLSH_CMD -u $admin_user -p $admin_pw -e "grant all on keyspace zonar to $zonar_user;"
#if [ $? -ne 0 ];then
#    echo "ERROR: Unable to set zonar permissions"
#    exit 3
#fi
#
# list users;
#
$CQLSH_CMD -u $admin_user -p $admin_pw -e "list users;"
if [ $? -ne 0 ];then
    echo "ERROR: Unable to list users"
    exit 3
fi
# list all permissions;
#$CQLSH_CMD -u $admin_user -p $admin_pw -e "list all permissions;"
#if [ $? -ne 0 ];then
#    echo "ERROR: Unable to list permissions"
#    exit 3
#fi
#
# do recomended procedure (node repair) after any cahnges of this sort.
$NODETOOL_CMD repair -local
if [ $? -ne 0 ];then
   echo "ERROR - could not nodetool repair -local this node"
fi
exit 0
