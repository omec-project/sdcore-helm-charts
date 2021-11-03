#!/bin/sh

# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: LicenseRef-ONF-Member-Only-1.0

set -xe

{{- if .Values.config.coreDump.enabled }}
cp /free5gc/smf/smf /tmp/coredump/
{{- end }}

cd /free5gc

cat config/smfcfg.conf
cat uerouting/uerouting.conf

GOTRACEBACK=crash ./smf/smf -smfcfg config/smfcfg.conf -uerouting uerouting/uerouting.conf
