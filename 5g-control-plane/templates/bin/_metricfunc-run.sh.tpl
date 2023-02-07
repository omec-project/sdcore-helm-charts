#!/bin/sh

# Copyright 2022-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

set -xe

IMGPATH={{ .Values.config.imagePath }}
{{- if .Values.config.coreDump.enabled }}
cp /sdcore/metrics /tmp/coredump/
{{- end }}

cd /metricfunc
cat config/metricscfg.conf

echo $PWD

GOTRACEBACK=crash /metricfunc/bin/metricfunc -metrics config/metricscfg.conf
