#!/bin/sh

# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

set -xe

{{- if .Values.config.coreDump.enabled }}
cp /simapp/bin/simapp /tmp/coredump/
{{- end }}

cd /simapp
cat config/simapp.yaml

./bin/simapp -simapp config/simapp.yaml
