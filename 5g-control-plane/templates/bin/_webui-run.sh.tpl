#!/bin/sh

# Copyright 2024-present Intel Corporation
# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

set -xe

{{- if .Values.config.coreDump.enabled }}
cp /usr/local/bin/webconsole /tmp/coredump/
{{- end }}

CFGPATH=/tmp
FILENAME=webuicfg.yaml
# copy config file from configmap (/opt) to a directory a non-root user can write (/tmp)
cp /opt/$FILENAME $CFGPATH/$FILENAME
cat $CFGPATH/$FILENAME
echo ""

# exec, so that the WebUI replaces this shell and receives the SIGTERM Kubernetes sends on
# a delete or a rollout: it shuts both of its servers down and exits (webconsole v3.1.4,
# omec-project/webconsole#590).
# Verified with its peers running; see #176.
exec env GOTRACEBACK=crash webconsole -cfg $CFGPATH/$FILENAME
