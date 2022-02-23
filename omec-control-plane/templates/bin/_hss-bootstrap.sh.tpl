#!/bin/bash

# Copyright 2018 Intel Corporation
# Copyright 2019-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

set -ex

function provision_users() {
    count=${1}
    imsi=${2}
    msisdn=${3}
    apn=${4}
    key=${5}
    opc=${6}
    sqn=${7}
    cassandra_ip=${8}
    mmeidentity=${9}
    mmerealm=${10}

    for (( i=1; i<=$count; i++ ))
    do
        echo "IMSI=$imsi MSISDN=$msisdn"
        cqlsh $cassandra_ip -e "INSERT INTO vhss.users_imsi (imsi, msisdn, access_restriction, key, opc, mmehost, mmeidentity_idmmeidentity, mmerealm, rand, sqn, subscription_data, supported_features) VALUES ('$imsi', $msisdn, 41, '$key', '$opc','$mmeidentity', 3, '$mmerealm', '2683b376d1056746de3b254012908e0e', $sqn, '{\"Subscription-Data\":{\"Access-Restriction-Data\":41,\"Subscriber-Status\":0,\"Network-Access-Mode\":2,\"Regional-Subscription-Zone-Code\":[\"0x0123\",\"0x4567\",\"0x89AB\",\"0xCDEF\",\"0x1234\",\"0x5678\",\"0x9ABC\",\"0xDEF0\",\"0x2345\",\"0x6789\"],\"MSISDN\":\"0x$msisdn\",\"AMBR\":{\"Max-Requested-Bandwidth-UL\":50000000,\"Max-Requested-Bandwidth-DL\":100000000},\"APN-Configuration-Profile\":{\"Context-Identifier\":0,\"All-APN-Configurations-Included-Indicator\":0,\"APN-Configuration\":{\"Context-Identifier\":0,\"PDN-Type\":0,\"Served-Party-IP-Address\":[\"0.0.0.0\"],\"Service-Selection\":\"$apn\",\"EPS-Subscribed-QoS-Profile\":{\"QoS-Class-Identifier\":9,\"Allocation-Retention-Priority\":{\"Priority-Level\":15,\"Pre-emption-Capability\":0,\"Pre-emption-Vulnerability\":0}},\"AMBR\":{\"Max-Requested-Bandwidth-UL\":50000000,\"Max-Requested-Bandwidth-DL\":100000000},\"PDN-GW-Allocation-Type\":0,\"MIP6-Agent-Info\":{\"MIP-Home-Agent-Address\":[\"172.26.17.183\"]}}},\"Subscribed-Periodic-RAU-TAU-Timer\":0}}', '{\"Supported-Features\":{\"Vendor-Id\": 10415, \"Feature-List-ID\": 2, \"Feature-List\": 134217728}}');"

        if [ $? -ne 0 ];then
           echo -e "oops! Something went wrong adding $imsi to vhss.users_imsi!\n"
           exit 1
        fi

        cqlsh $cassandra_ip -e "INSERT INTO vhss.msisdn_imsi (msisdn, imsi) VALUES ($msisdn, '$imsi');"
        if [ $? -ne 0 ];then
           echo -e "oops! Something went wrong adding $imsi to vhss.msisdn_imsi!\n"
           exit 1
        fi

        echo -e "Added $imsi\n"

        imsi=`expr $imsi + 1`;
        msisdn=`expr $msisdn + 1`
    done
}

function provision_staticusers() {
    imsi=${1}
    msisdn=${2}
    apn=${3}
    key=${4}
    opc=${5}
    sqn=${6}
    cassandra_ip=${7}
    mmeidentity=${8}
    mmerealm=${9}
    staticAddr=${10}

    echo "IMSI=$imsi MSISDN=$msisdn"
    cqlsh $cassandra_ip -e "INSERT INTO vhss.users_imsi (imsi, msisdn, access_restriction, key, opc, mmehost, mmeidentity_idmmeidentity, mmerealm, rand, sqn, subscription_data, supported_features) VALUES ('$imsi', $msisdn, 41, '$key', '$opc','$mmeidentity', 3, '$mmerealm', '2683b376d1056746de3b254012908e0e', $sqn, '{\"Subscription-Data\":{\"Access-Restriction-Data\":41,\"Subscriber-Status\":0,\"Network-Access-Mode\":2,\"Regional-Subscription-Zone-Code\":[\"0x0123\",\"0x4567\",\"0x89AB\",\"0xCDEF\",\"0x1234\",\"0x5678\",\"0x9ABC\",\"0xDEF0\",\"0x2345\",\"0x6789\"],\"MSISDN\":\"0x$msisdn\",\"AMBR\":{\"Max-Requested-Bandwidth-UL\":50000000,\"Max-Requested-Bandwidth-DL\":100000000},\"APN-Configuration-Profile\":{\"Context-Identifier\":0,\"All-APN-Configurations-Included-Indicator\":0,\"APN-Configuration\":{\"Context-Identifier\":0,\"PDN-Type\":0,\"Served-Party-IP-Address\":[\"$staticAddr\"],\"Service-Selection\":\"$apn\",\"EPS-Subscribed-QoS-Profile\":{\"QoS-Class-Identifier\":9,\"Allocation-Retention-Priority\":{\"Priority-Level\":15,\"Pre-emption-Capability\":0,\"Pre-emption-Vulnerability\":0}},\"AMBR\":{\"Max-Requested-Bandwidth-UL\":50000000,\"Max-Requested-Bandwidth-DL\":100000000},\"PDN-GW-Allocation-Type\":0,\"MIP6-Agent-Info\":{\"MIP-Home-Agent-Address\":[\"172.26.17.183\"]}}},\"Subscribed-Periodic-RAU-TAU-Timer\":0}}', '{\"Supported-Features\":{\"Vendor-Id\": 10415, \"Feature-List-ID\": 2, \"Feature-List\": 134217728}}');"

    cqlsh $cassandra_ip -e "INSERT INTO vhss.msisdn_imsi (msisdn, imsi) VALUES ($msisdn, '$imsi');"
    echo -e "Added $imsi\n"
}

function provision_mme() {
    id=$1
    isdn=$2
    host=$3
    realm=$4
    uereachability=$5
    cassandra_ip=$6

    cqlsh $cassandra_ip -e "INSERT INTO vhss.mmeidentity (idmmeidentity, mmeisdn, mmehost, mmerealm, ue_reachability) VALUES ($id, '$isdn', '$host', '$realm', $uereachability);"
    if [ $? -ne 0 ];then
       echo -e "oops! Something went wrong adding to vhss.mmeidentity!\n"
       exit 1
    fi

    cqlsh $cassandra_ip -e "INSERT INTO vhss.mmeidentity_host (idmmeidentity, mmeisdn, mmehost, mmerealm, ue_reachability) VALUES ($id, '$isdn', '$host', '$realm', $uereachability);"
    if [ $? -ne 0 ];then
       echo -e "oops! Something went wrong adding to vhss.mmeidentity_host!\n"
       exit 1
    fi

    echo -e "Added mme $id\n"
}

until cqlsh --file /opt/c3po/hssdb/oai_db.cql {{ .Values.config.hss.hssdb }};
    do echo "Provisioning HSSDB";
    sleep 2;
done

{{- if .Values.config.hss.bootstrap.enabled }}
{{- range .Values.config.hss.bootstrap.users }}
provision_users \
    {{ .count }} \
    {{ .imsiStart }} \
    {{ .msisdnStart }} \
    {{ .apn }} \
    {{ .key }} \
    {{ .opc }} \
    {{ .sqn }} \
    {{ $.Values.config.hss.hssdb }} \
    {{ .mme_identity }} \
    {{ .mme_realm }}
{{- end }}

{{- range .Values.config.hss.bootstrap.staticusers }}
provision_staticusers \
    {{ .imsi }} \
    {{ .msisdn }} \
    {{ .apn }} \
    {{ .key }} \
    {{ .opc }} \
    {{ .sqn }} \
    {{ $.Values.config.hss.hssdb }} \
    {{ .mme_identity }} \
    {{ .mme_realm }} \
    {{ .staticAddr }}
{{- end }}

{{- range .Values.config.hss.bootstrap.mmes }}
provision_mme \
    {{ .id }} \
    {{ .isdn }} \
    {{ .mme_identity }} \
    {{ .mme_realm }} \
    {{ .unreachability }} \
    {{ $.Values.config.hss.hssdb }}
{{- end }}
{{- end }}

