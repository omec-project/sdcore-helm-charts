#!/bin/sh

# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

set -xe

{{- if .Values.config.coreDump.enabled }}
cp /free5gc/udr/udr /tmp/coredump/
{{- end }}

cd /free5gc

cat config/udrcfg.conf

GOTRACEBACK=crash ./udr/udr -udrcfg config/udrcfg.conf
