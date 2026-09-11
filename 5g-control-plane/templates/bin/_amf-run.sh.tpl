#!/bin/sh

# Copyright 2024-present Intel Corporation
# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

set -xe

{{- if .Values.config.coreDump.enabled }}
cp /usr/local/bin/amf /tmp/coredump/
{{- end }}

CFGPATH=/home
FILENAME=amfcfg.yaml
# copy config file from configmap (/opt) to a general directory (/home)
cp /opt/$FILENAME $CFGPATH/$FILENAME
cat $CFGPATH/$FILENAME
echo ""

# exec, so that the AMF replaces this shell and receives the SIGTERM Kubernetes sends on
# a delete or a rollout. Without it the signal stops at the shell, which does not forward
# it: the AMF never runs its shutdown sequence - no NRF deregistration, no AMF-unavailable
# status notification to its peers, no subscription cleanup - and the container ends only
# when the termination grace period expires and the kubelet sends SIGKILL, so every
# rollout waits out that period in full.
#
# The other run scripts in this chart have the same gap. They are left alone here because
# turning the signal on makes each NF's shutdown path reachable for the first time, and
# that path has only been exercised for the AMF, where it turned out to panic
# (omec-project/amf#811). One at a time, each with its own verification.
exec env GOTRACEBACK=crash amf -cfg $CFGPATH/$FILENAME
