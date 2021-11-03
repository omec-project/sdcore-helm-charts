#!/bin/sh

# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: LicenseRef-ONF-Member-Only-1.0

set -xe

{{- if .Values.config.coreDump.enabled }}
cp /free5gc/amf/amf /tmp/coredump/
{{- end }}

#cat config files
cd /free5gc
cat ./config/gnb.conf
cat /etc/hosts
ip route add 192.168.252.0/24 via 192.168.251.1
# Disabling checksum offloading to hardware
ethtool -K enb tx off
sleep infinity
