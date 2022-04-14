#!/bin/sh

# Copyright 2021-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

set -xe

{{- if .Values.config.coreDump.enabled }}
cp /sdcore/bin/sctplb /tmp/coredump/
{{- end }}

cd /sdcore

cat config/sctplb.yaml

GOTRACEBACK=crash ./bin/sctplb config/sctplb.yaml
