#!/bin/sh

# SPDX-FileCopyrightText: 2022-present Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0

set -xe

{{- if .Values.config.coreDump.enabled }}
cp /bin/upf-adapter /tmp/coredump/
{{- end }}

cd /free5gc

cat config/config.yaml

GOTRACEBACK=crash /bin/upf-adapter config/config.yaml
