#!/bin/sh

# Copyright 2024-present Intel Corporation
# Copyright 2022-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

set -xe

{{- if .Values.config.coreDump.enabled }}
cp /usr/local/bin/metricfunc /tmp/coredump/
{{- end }}

CFGPATH=/tmp
FILENAME=metricscfg.yaml
# copy config file from configmap (/opt) to a directory a non-root user can write (/tmp)
cp /opt/$FILENAME $CFGPATH/$FILENAME
cat $CFGPATH/$FILENAME
echo ""

# exec, so that metricfunc replaces this shell and receives the SIGTERM Kubernetes sends
# on a delete or a rollout: it shuts its API and metrics servers down and exits
# (metricfunc v2.1.3, omec-project/metricfunc#318).
# Verified with its peers running; see #176.
exec env GOTRACEBACK=crash metricfunc -cfg $CFGPATH/$FILENAME
