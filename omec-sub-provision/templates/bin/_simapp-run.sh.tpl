#!/bin/sh

# Copyright 2020-present Open Networking Foundation
# Copyright 2024-present Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0

set -xe

{{- if .Values.config.coreDump.enabled }}
cp /usr/local/bin/simapp /tmp/coredump/
{{- end }}

CFGPATH=/home
FILENAME=simapp.yaml
# copy config file from configmap (/opt) to a general directory (/home)
cp /opt/$FILENAME $CFGPATH/$FILENAME
cat $CFGPATH/$FILENAME
echo ""

GOTRACEBACK=crash simapp -cfg $CFGPATH/$FILENAME
