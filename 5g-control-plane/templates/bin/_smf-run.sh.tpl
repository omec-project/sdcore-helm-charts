#!/bin/sh

# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: LicenseRef-ONF-Member-Only-1.0

set -xe

DIR=""
if [ -d "/free5gc/smf" ]; then
  DIR="/free5gc"
  echo "free5gc directory exist"
fi
if [ -d "/sdcore/smf" ]; then
  DIR="/sdcore"
  echo "sdcore directory exist"
fi

{{- if .Values.config.coreDump.enabled }}
cp $DIR/smf/smf /tmp/coredump/
{{- end }}

cd $DIR

cat config/smfcfg.conf
cat uerouting/uerouting.conf

GOTRACEBACK=crash ./smf/smf -smfcfg config/smfcfg.conf -uerouting uerouting/uerouting.conf
