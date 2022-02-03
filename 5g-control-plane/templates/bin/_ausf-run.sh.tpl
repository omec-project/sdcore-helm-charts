#!/bin/sh

# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: LicenseRef-ONF-Member-Only-1.0

set -xe

DIR=""
if [ -d "/free5gc/ausf" ]; then
  DIR="/free5gc"
  echo "free5gc directory exist"
fi
if [ -d "/sdcore/ausf" ]; then
  DIR="/sdcore"
  echo "sdcore directory exist"
fi

{{- if .Values.config.coreDump.enabled }}
cp $DIR/ausf/ausf /tmp/coredump/
{{- end }}

cd $DIR
cat config/ausfcfg.conf

GOTRACEBACK=crash ./ausf/ausf -ausfcfg config/ausfcfg.conf
