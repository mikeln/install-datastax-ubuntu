#!/usr/bin/env bash
cloud_type=$1
echo "Installing OpsCenter"

echo "Adding the DataStax repository"
if [[ $cloud_type == "gce" ]] || [[ $cloud_type == "gke" ]]; then
  echo "deb http://debian.datastax.com/community stable main" | sudo tee -a /etc/apt/sources.list.d/datastax.community.list 
else
  echo "deb http://debian.datastax.com/community stable main" | sudo tee -a /etc/apt/sources.list.d/datastax.community.list
fi

curl -L http://debian.datastax.com/debian/repo_key | sudo apt-key add -
#
# opscenter version 6.0.4 (5.2.1)
apt-get update
apt-get -y install opscenter=6.0.4
