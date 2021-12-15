#!/bin/sh

# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: LicenseRef-ONF-Member-Only-1.0

set -xe

{{- if .Values.config.coreDump.enabled }}
cp /dbtestapp/bin/dbtestapp /tmp/coredump/
{{- end }}

/dbtestapp/bin/testapp