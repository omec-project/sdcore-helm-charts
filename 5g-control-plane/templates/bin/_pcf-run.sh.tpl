#!/bin/sh

# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: LicenseRef-ONF-Member-Only-1.0

set -xe

DIR=""
if [ -d "/free5gc/pcf" ]; then
  DIR="/free5gc"
  echo "free5gc directory exist"
fi
if [ -d "/sdcore/pcf" ]; then
  DIR="/sdcore"
  echo "sdcore directory exist"
fi

{{- if .Values.config.coreDump.enabled }}
cp $DIR/pcf/pcf /tmp/coredump/
{{- end }}

cd $DIR

cat config/pcfcfg.conf

GOTRACEBACK=crash ./pcf/pcf -pcfcfg config/pcfcfg.conf
