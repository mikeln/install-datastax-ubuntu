#!/usr/bin/env bash

cloud_type=$1

echo "Installing DataStax Community DDC"

echo "Adding the DataStax repository"
if [[ $cloud_type == "gce" ]] || [[ $cloud_type == "gke" ]]; then
  echo "deb http://debian.datastax.com/datastax-ddc 3.2 main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
else
  echo "deb http://debian.datastax.com/datastax-ddc 3.2 main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
fi

#
# Debian systems only:
# In /etc/apt/sources.list, find the line that describes your source repository for Debian and add contrib non-free to the end of the line. For example:
# deb http://some.debian.mirror/debian/ $distro main contrib non-free
# This allows installation of the Oracle JVM instead of the OpenJDK JVM.
# Save and close the file when you are done adding/editing your sources.
#
curl -L http://debian.datastax.com/debian/repo_key | sudo apt-key add -
apt-get -y update


echo "Running apt-get install ddc"
apt-get -y install datastax-ddc
apt-get -y install datastax-ddc-tools

echo "Stopping and clearing default server setup"
service casssandra stop
rm -rf /var/lib/cassandra/data/system/*

echo "Adding the DataStax repository dsc21"
if [[ $cloud_type == "gce" ]] || [[ $cloud_type == "gke" ]]; then
   echo "deb http://debian.datastax.com/community stable main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
else
   echo "deb http://debian.datastax.com/community stable main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
fi
curl -L http://debian.datastax.com/debian/repo_key | sudo apt-key add -
apt-get -y update
echo "Running apt-get install datastax-agent"
#opscenter_version=6.0.4
opscenter_version=5.2.1
apt-get -y install datastax-agent=$opscenter_version

# The install of dse creates a cassandra user, so now we can do this:
chown cassandra /mnt
chgrp cassandra /mnt
