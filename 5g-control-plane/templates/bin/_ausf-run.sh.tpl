#!/bin/sh

# Copyright 2024-present Intel Corporation
# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

set -xe

{{- if .Values.config.coreDump.enabled }}
cp /usr/local/bin/ausf /tmp/coredump/
{{- end }}

CFGPATH=/home
FILENAME=ausfcfg.yaml
# copy config file from configmap (/opt) to a general directory (/home)
cp /opt/$FILENAME $CFGPATH/$FILENAME
cat $CFGPATH/$FILENAME
echo ""

GOTRACEBACK=crash ausf -cfg $CFGPATH/$FILENAME
