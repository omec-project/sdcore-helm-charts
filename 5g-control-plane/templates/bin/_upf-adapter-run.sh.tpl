#!/bin/sh

# SPDX-FileCopyrightText: 2022-present Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0

set -xe

{{- if .Values.config.coreDump.enabled }}
cp /aether/upfadapter /tmp/coredump/
{{- end }}

cd /aether

cat config/config.yaml

GOTRACEBACK=crash ./upfadapter config/config.yaml
