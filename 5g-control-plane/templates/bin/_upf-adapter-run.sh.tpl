#!/bin/sh

# SPDX-FileCopyrightText: 2022-present Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0

set -xe

{{- if .Values.config.coreDump.enabled }}
cp /usr/local/bin/upfadapter /tmp/coredump/
{{- end }}

CFGPATH=/tmp
FILENAME=upfadaptercfg.yaml
# copy config file from configmap (/opt) to a directory a non-root user can write (/tmp)
cp /opt/$FILENAME $CFGPATH/$FILENAME
cat $CFGPATH/$FILENAME
echo ""

GOTRACEBACK=crash upfadapter -cfg $CFGPATH/$FILENAME
