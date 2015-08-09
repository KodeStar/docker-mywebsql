#!/bin/bash


apt-get update -qq && \
apt-get --only-upgrade install \
percona-server-server-5.6 \
percona-server-tokudb-5.6 -qqy
