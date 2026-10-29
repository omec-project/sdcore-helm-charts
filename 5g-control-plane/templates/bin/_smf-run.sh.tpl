#!/bin/sh

# Copyright 2024-present Intel Corporation
# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

set -xe

{{- if .Values.config.coreDump.enabled }}
cp /usr/local/bin/smf /tmp/coredump/
{{- end }}

CFGPATH=/tmp
FILENAME=smfcfg.yaml
UEFILENAME=uerouting.yaml
# copy config file from configmap (/opt) to a directory a non-root user can write (/tmp)
cp /opt/$FILENAME $CFGPATH/$FILENAME
cp /opt/$UEFILENAME $CFGPATH/$UEFILENAME
{{- if .Values.mongodb.enabled }}
# The MongoDB URL carries the operator's password: printed without it.
sed -E 's#(mongodb://[^:/@]*:)[^@]*@#\1****@#g' $CFGPATH/$FILENAME
{{- else }}
cat $CFGPATH/$FILENAME
{{- end }}
echo ""
cat $CFGPATH/$UEFILENAME
echo ""

# exec, so that the SMF replaces this shell and receives the SIGTERM Kubernetes sends on
# a delete or a rollout, and runs its shutdown sequence: it deregisters from the NRF.
# Verified with its peers running; see #176 and the AMF script.
exec env GOTRACEBACK=crash GOGC=200 smf -cfg $CFGPATH/$FILENAME -uerouting $CFGPATH/$UEFILENAME
