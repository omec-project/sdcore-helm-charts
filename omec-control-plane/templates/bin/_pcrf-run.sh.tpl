#!/bin/bash

# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

set -ex

{{- if .Values.config.coreDump.enabled }}
cp /bin/pcrf /tmp/coredump/
{{- end }}

CONF_DIR="/opt/c3po/pcrf/conf"
LOGS_DIR="/opt/c3po/pcrf/logs"
#TODO - Need to remove logs directory
mkdir -p $CONF_DIR $LOGS_DIR

cp /etc/pcrf/conf/{acl.conf,pcrf.json,pcrf.conf,oss.json,subscriber_mapping.json} $CONF_DIR
cat $CONF_DIR/{pcrf.json,pcrf.conf}

cd $CONF_DIR
make_certs.sh {{ tuple "pcrf" "host" . | include "omec-control-plane.diameter_endpoint" }} {{ tuple "pcrf" "realm" . | include "omec-control-plane.diameter_endpoint" }}

cd ..
pcrf -j $CONF_DIR/pcrf.json
