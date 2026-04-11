#!/bin/bash

# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

{{- $config := "up4" }}
{{- if .Values.config.upf.closedLoop }}
{{- $config = "closed_loop" }}
{{- end }}

set -ex

while true; do
    bessctl daemon reset >/dev/null 2>&1 || true
    if bessctl run /opt/bess/bessctl/conf/{{ $config }}; then
        break
    fi
    sleep 2
done
