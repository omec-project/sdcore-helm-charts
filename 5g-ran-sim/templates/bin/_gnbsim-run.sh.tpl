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

{{- if not .Values.config.gnbsim.singleInterface }}
{{- range .Values.config.gnbsim.networkTopo }}
ip route add {{ .upfAddr }} via {{ .upfGw }}
{{- end }}

# Disabling checksum offloading to hardware
ethtool -K enb tx off
{{- end }}
sleep infinity
