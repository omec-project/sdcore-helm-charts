#!/bin/sh

# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: LicenseRef-ONF-Member-Only-1.0

set -xe

DIR=""
if [ -d "/free5gc/webconsole" ]; then
  DIR="/free5gc"
  echo "free5gc directory exist"
fi
if [ -d "/sdcore/webconsole" ]; then
  DIR="/sdcore"
  echo "sdcore directory exist"
fi

{{- if .Values.config.coreDump.enabled }}
cp $DIR/webconsole/webconsole /tmp/coredump/
{{- end }}

cd $DIR

cat config/webuicfg.conf

GOTRACEBACK=crash ./webconsole/webconsole -webuicfg config/webuicfg.conf
