#!/bin/sh

# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

set -xe

{{- if .Values.config.coreDump.enabled }}
cp /free5gc/udm/udm /tmp/coredump/
{{- end }}

cd /free5gc

cat config/udmcfg.conf

GOTRACEBACK=crash ./udm/udm -udmcfg config/udmcfg.conf
