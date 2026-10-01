#!/bin/sh

# Copyright 2024-present Intel Corporation
# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

set -xe

{{- if .Values.config.coreDump.enabled }}
cp /usr/local/bin/udr /tmp/coredump/
{{- end }}

CFGPATH=/tmp
FILENAME=udrcfg.yaml
# copy config file from configmap (/opt) to a directory a non-root user can write (/tmp)
cp /opt/$FILENAME $CFGPATH/$FILENAME
cat $CFGPATH/$FILENAME
echo ""

# exec, so that the UDR replaces this shell and receives the SIGTERM Kubernetes sends on
# a delete or a rollout, and runs its shutdown sequence: it deregisters from the NRF.
# Verified with its peers running; see #176 and the AMF script.
exec env GOTRACEBACK=crash udr -cfg $CFGPATH/$FILENAME
