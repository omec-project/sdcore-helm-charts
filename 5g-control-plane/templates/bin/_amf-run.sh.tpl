#!/bin/sh

# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: LicenseRef-ONF-Member-Only-1.0

set -xe

{{- if .Values.config.coreDump.enabled }}
cp /free5gc/amf/amf /tmp/coredump/
{{- end }}

cd /free5gc
cat config/amfcfg.conf

GOTRACEBACK=crash ./amf/amf -amfcfg config/amfcfg.conf
