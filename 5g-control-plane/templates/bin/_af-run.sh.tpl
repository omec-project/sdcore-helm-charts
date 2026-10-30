#!/bin/sh

# Copyright (C) 2026-present Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0

set -xe

{{- if .Values.config.coreDump.enabled }}
cp /usr/local/bin/af /tmp/coredump/
{{- end }}

CFGPATH=/tmp
FILENAME=afcfg.yaml
# copy config file from configmap (/opt) to a directory a non-root user can write (/tmp)
cp /opt/$FILENAME $CFGPATH/$FILENAME
cat $CFGPATH/$FILENAME
echo ""

# exec, so that the AF replaces this shell and receives the SIGTERM Kubernetes sends on
# a delete or a rollout, and runs its shutdown sequence: it deregisters from the NRF.
exec env GOTRACEBACK=crash af -cfg $CFGPATH/$FILENAME
