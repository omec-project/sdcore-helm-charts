#!/bin/bash

# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

set -ex

until bessctl run /opt/bess/bessctl/conf/up4; do
    sleep 2;
done;
