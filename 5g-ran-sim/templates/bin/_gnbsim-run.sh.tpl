#!/bin/sh

# Copyright 2024-present Intel Corporation
# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

set -xe

{{- if .Values.config.coreDump.enabled }}
cp /usr/local/bin/gnbsim /tmp/coredump/
{{- end }}

CFGPATH=/home
FILENAME=gnbsimcfg.yaml
# copy config file from configmap (/opt) to a general directory (/home)
cp /opt/$FILENAME $CFGPATH/$FILENAME
cat $CFGPATH/$FILENAME
echo ""
cat /etc/hosts
echo ""

{{- define "gnbiplist" -}}
{{- join "," .Values.config.gnbsim.gnb.ips }}
{{- end -}}

{{- if not .Values.config.gnbsim.singleInterface }}
{{- range .Values.config.gnbsim.networkTopo }}
ip route replace {{ .upfAddr }} via {{ .upfGw }}
{{- end }}
{{- end }}

{{- if .Values.config.gnbsim.httpServer.enable}}
gnbsim --cfg $CFGPATH/$FILENAME
{{- else }}
sleep infinity
{{- end }}
