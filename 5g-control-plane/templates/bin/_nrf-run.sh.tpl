#!/bin/sh

# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

set -xe

{{- if .Values.config.coreDump.enabled }}
cp /free5gc/nrf/nrf /tmp/coredump/
{{- end }}

cd /free5gc

cat config/nrfcfg.conf

GOTRACEBACK=crash ./nrf/nrf -nrfcfg config/nrfcfg.conf
