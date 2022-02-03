#!/bin/sh

# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: LicenseRef-ONF-Member-Only-1.0

set -xe

DIR=""
if [ -d "/free5gc/udr" ]; then
  DIR="/free5gc"
  echo "free5gc directory exist"
fi
if [ -d "/sdcore/udr" ]; then
  DIR="/sdcore"
  echo "sdcore directory exist"
fi

{{- if .Values.config.coreDump.enabled }}
cp $DIR/udr/udr /tmp/coredump/
{{- end }}

cd $DIR

cat config/udrcfg.conf

GOTRACEBACK=crash ./udr/udr -udrcfg config/udrcfg.conf
