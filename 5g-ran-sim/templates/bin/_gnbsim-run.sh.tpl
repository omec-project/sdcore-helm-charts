#!/bin/sh

# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

set -xe

{{- if .Values.config.coreDump.enabled }}
cp /gnbsim/bin/gnbsim /tmp/coredump/
{{- end }}

cd /gnbsim
cat ./config/gnb.conf
cat /etc/hosts

{{- define "gnbiplist" -}}
{{- join "," .Values.config.gnbsim.gnb.ips }}
{{- end -}}

{{- if not .Values.config.gnbsim.singleInterface }}
{{- range .Values.config.gnbsim.networkTopo }}
ip route replace {{ .upfAddr }} via {{ .upfGw }}
{{- end }}
{{- end }}

{{- if .Values.config.gnbsim.httpServer.enable}}
cd /gnbsim
./bin/gnbsim --cfg ./config/gnb.conf
{{- else }}
sleep infinity
{{- end }}
