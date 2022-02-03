#!/bin/sh

# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: LicenseRef-ONF-Member-Only-1.0

set -xe

DIR=""
if [ -d "/free5gc/nssf" ]; then
  DIR="/free5gc"
  echo "free5gc directory exist"
fi
if [ -d "/sdcore/nssf" ]; then
  DIR="/sdcore"
  echo "sdcore directory exist"
fi

{{- if .Values.config.coreDump.enabled }}
cp $DIR/nssf/nssf /tmp/coredump/
{{- end }}

cd $DIR

cat config/nssfcfg.conf

GOTRACEBACK=crash ./nssf/nssf -nssfcfg config/nssfcfg.conf
