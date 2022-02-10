#!/bin/bash

# Copyright 2019-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

set -ex

{{- if .Values.config.coreDump.enabled }}
cp /bin/hss /tmp/coredump/
{{- end }}

CONF_DIR="/opt/c3po/hss/conf"
LOGS_DIR="/opt/c3po/hss/logs"
mkdir -p $CONF_DIR $LOGS_DIR

cp /etc/hss/conf/{acl.conf,hss.json,hss.conf,oss.json} $CONF_DIR
cat $CONF_DIR/{hss.json,hss.conf}

cd $CONF_DIR
make_certs.sh {{ tuple "hss" "host" . | include "omec-control-plane.diameter_endpoint" }} {{ tuple "hss" "realm" . | include "omec-control-plane.diameter_endpoint" }}

cd ..
hss -j $CONF_DIR/hss.json
