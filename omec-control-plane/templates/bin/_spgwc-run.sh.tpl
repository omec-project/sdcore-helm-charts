#!/bin/bash

# Copyright 2019-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

APPLICATION=$1
set -xe

mkdir -p /opt/cp/config
cd /opt/cp/config
cp /etc/cp/config/{*.json,*.conf} .

case $APPLICATION in
    "ngic_controlplane")
      echo "Starting ngic controlplane app"
      cat /opt/cp/config/cp.json
      cat /opt/cp/config/subscriber_mapping.json
      {{- if .Values.config.coreDump.enabled }}
      cp /bin/ngic_controlplane /tmp/coredump/
      {{- end }}

      ngic_controlplane -f /etc/cp/config/
      ;;

    "gx-app")
      echo "Starting gx-app"
      SPGWC_IDENTITY={{ tuple "spgwc" "identity" . | include "omec-control-plane.diameter_endpoint" | quote }};
      DIAMETER_HOST=$(echo $SPGWC_IDENTITY| cut -d'.' -f1)
      DIAMETER_REALM={{ tuple "spgwc" "realm" . | include "omec-control-plane.diameter_endpoint" | quote }};
      chmod +x /bin/make_certs.sh
      cp /bin/make_certs.sh /opt/cp/config
      /bin/make_certs.sh $DIAMETER_HOST $DIAMETER_REALM
      {{- if .Values.config.coreDump.enabled }}
      cp /bin/gx_app /tmp/coredump/
      {{- end }}
      cd /opt/cp/
      gx_app
      ;;

    *)
      echo "invalid app $APPLICATION"
      ;;
esac
