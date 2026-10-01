#!/bin/sh

# Copyright 2024-present Intel Corporation
# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

set -xe

{{- if .Values.config.coreDump.enabled }}
cp /usr/local/bin/nrf /tmp/coredump/
{{- end }}

CFGPATH=/tmp
FILENAME=nrfcfg.yaml
# copy config file from configmap (/opt) to a directory a non-root user can write (/tmp)
cp /opt/$FILENAME $CFGPATH/$FILENAME
cat $CFGPATH/$FILENAME
echo ""

# exec, so that the NRF replaces this shell and receives the SIGTERM Kubernetes sends on
# a delete or a rollout, and runs its shutdown sequence.
# Verified with its peers running; see #176 and the AMF script.
exec env GOTRACEBACK=crash nrf -cfg $CFGPATH/$FILENAME
