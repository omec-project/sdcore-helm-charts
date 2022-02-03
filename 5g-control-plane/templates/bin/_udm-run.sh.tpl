#!/bin/sh

# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: LicenseRef-ONF-Member-Only-1.0

set -xe

DIR=""
if [ -d "/free5gc/udm" ]; then
  DIR="/free5gc"
  echo "free5gc directory exist"
fi
if [ -d "/sdcore/udm" ]; then
  DIR="/sdcore"
  echo "sdcore directory exist"
fi

{{- if .Values.config.coreDump.enabled }}
cp $DIR/udm/udm /tmp/coredump/
{{- end }}

cd $DIR

cat config/udmcfg.conf

GOTRACEBACK=crash ./udm/udm -udmcfg config/udmcfg.conf
