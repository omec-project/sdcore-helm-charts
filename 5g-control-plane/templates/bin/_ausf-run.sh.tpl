#!/bin/sh

# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

set -xe

{{- if .Values.config.coreDump.enabled }}
cp /free5gc/ausf/ausf /tmp/coredump/
{{- end }}

cd /free5gc
cat config/ausfcfg.conf

GOTRACEBACK=crash ./ausf/ausf -ausfcfg config/ausfcfg.conf
