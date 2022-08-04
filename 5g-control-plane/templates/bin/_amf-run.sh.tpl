#!/bin/bash

# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

set -xe

IMGPATH={{ .Values.config.imagePath }}
{{- if .Values.config.coreDump.enabled }}
cp $IMGPATH/amf/amf /tmp/coredump/
{{- end }}

cd $IMGPATH
cat config/amfcfg.conf

#GOTRACEBACK=crash ./amf/amf -amfcfg config/amfcfg.conf
