#!/bin/sh

# Copyright 2024-present Intel Corporation
# Copyright 2021-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

set -xe

{{- if .Values.config.coreDump.enabled }}
cp /usr/local/bin/sctplb /tmp/coredump/
{{- end }}

CFGPATH=/tmp
FILENAME=sctplb.yaml
# copy config file from configmap (/opt) to a directory a non-root user can write (/tmp)
cp /opt/$FILENAME $CFGPATH/$FILENAME
cat $CFGPATH/$FILENAME
echo ""

# exec, so that sctplb replaces this shell and receives the SIGTERM Kubernetes sends on a
# delete or a rollout: it drains its streams to the AMF and closes its connections before
# it exits (sctplb v1.9.4, omec-project/sctplb#306).
# Verified with its peers running; see #176.
exec env GOTRACEBACK=crash sctplb -cfg $CFGPATH/$FILENAME
