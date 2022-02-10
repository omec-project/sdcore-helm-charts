#!/bin/sh

# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

set -xe

{{- if .Values.config.coreDump.enabled }}
cp /free5gc/pcf/pcf /tmp/coredump/
{{- end }}

cd /free5gc

cat config/pcfcfg.conf

GOTRACEBACK=crash ./pcf/pcf -pcfcfg config/pcfcfg.conf
