#!/usr/bin/env bash

cloud_type=$1

echo "Installing DataStax Community DSC21"

echo "Adding the DataStax repository"
if [[ $cloud_type == "gce" ]] || [[ $cloud_type == "gke" ]]; then
  echo "deb http://debian.datastax.com/community stable main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
else
  echo "deb http://debian.datastax.com/community stable main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
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


dsc_version=2.1.10
echo "Running apt-get install dsc $dsc_version"
apt-get -y install dsc21=$dsc_version-1 cassandra=$dsc_version cassandra-tools=$dsc_version

echo "Stopping and clearing default server setup"
service casssandra stop
rm -rf /var/lib/cassandra/data/system/*

echo "Running apt-get install datastax-agent"
#opscenter_version=6.0.4
opscenter_version=5.2.5
apt-get -y install datastax-agent=$opscenter_version

# The install of dse creates a cassandra user, so now we can do this:
chown cassandra /mnt
chgrp cassandra /mnt
