#!/bin/sh

# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

set -xe

{{- if .Values.config.coreDump.enabled }}
cp /free5gc/nssf/nssf /tmp/coredump/
{{- end }}

cd /free5gc

cat config/nssfcfg.conf

GOTRACEBACK=crash ./nssf/nssf -nssfcfg config/nssfcfg.conf
