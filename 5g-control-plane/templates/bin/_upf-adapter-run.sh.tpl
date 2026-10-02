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

# exec, so that the UPF adapter replaces this shell and receives the SIGTERM Kubernetes
# sends on a delete or a rollout: it shuts its HTTP server down, closes the PFCP socket
# and exits (upfadapter v2.2.1, omec-project/upfadapter#126).
# Verified with its peers running; see #176.
exec env GOTRACEBACK=crash upfadapter -cfg $CFGPATH/$FILENAME
