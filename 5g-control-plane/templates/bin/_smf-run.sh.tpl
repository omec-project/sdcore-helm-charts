#!/bin/bash

# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

set -xe

IMGPATH={{ .Values.config.imagePath }}
{{- if .Values.config.coreDump.enabled }}
cp /free5gc/smf/smf /tmp/coredump/
{{- end }}

cd $IMGPATH

cat config/smfcfg.conf
cat uerouting/uerouting.conf

#GOTRACEBACK=crash ./smf/smf -smfcfg config/smfcfg.conf -uerouting uerouting/uerouting.conf
