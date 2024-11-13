#!/bin/sh

# Copyright 2024-present Intel Corporation
# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

set -xe

{{- if .Values.config.coreDump.enabled }}
cp /usr/local/bin/smf /tmp/coredump/
{{- end }}

CFGPATH=/home
FILENAME=smfcfg.yaml
UEFILENAME=uerouting.yaml
# copy config file from configmap (/opt) to a general directory (/home)
cp /opt/$FILENAME $CFGPATH/$FILENAME
cp /opt/$UEFILENAME $CFGPATH/$UEFILENAME
cat $CFGPATH/$FILENAME
echo ""
cat $CFGPATH/$UEFILENAME
echo ""

GOTRACEBACK=crash smf -cfg $CFGPATH/$FILENAME -uerouting $CFGPATH/$UEFILENAME
