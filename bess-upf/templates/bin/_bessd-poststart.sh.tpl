#!/bin/bash

# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

{{- $config := "up4" -}}
{{- if .Values.config.upf.closedLoop -}}
{{- $config = "closed_loop" -}}
{{- end -}}

set -ex

until bessctl run /opt/bess/bessctl/conf/{{ $config }}; do
    sleep 2;
done;
