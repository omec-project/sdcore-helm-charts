#!/bin/sh

# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: LicenseRef-ONF-Member-Only-1.0

set -xe

DIR=""
if [ -d "/free5gc/amf" ]; then
  DIR="/free5gc"
  echo "free5gc directory exist" 
fi
if [ -d "/sdcore/amf" ]; then
  DIR="/sdcore"
  echo "sdcore directory exist" 
fi 

{{- if .Values.config.coreDump.enabled }}
cp $DIR/amf/amf /tmp/coredump/
{{- end }}

cd $DIR
cat config/amfcfg.conf

GOTRACEBACK=crash ./amf/amf -amfcfg config/amfcfg.conf
