#!/bin/sh

# Copyright 2020-present Open Networking Foundation
# Copyright 2024-present Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0

set -xe

{{- if .Values.config.coreDump.enabled }}
cp /usr/local/bin/simapp /tmp/coredump/
{{- end }}

CFGPATH=/tmp
FILENAME=simapp.yaml
# copy config file from configmap (/opt) to a directory a non-root user can write (/tmp)
cp /opt/$FILENAME $CFGPATH/$FILENAME
cat $CFGPATH/$FILENAME
echo ""

# exec, so that simapp replaces this shell and receives the SIGTERM Kubernetes sends on a
# delete or a rollout: it shuts its /synchronize server down and exits (simapp v1.9.5,
# omec-project/simapp#300).
# Verified with its peers running; see #176.
exec env GOTRACEBACK=crash simapp -cfg $CFGPATH/$FILENAME
