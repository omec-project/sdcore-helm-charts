<!--
Copyright 2024-present Intel Corporation
SPDX-License-Identifier: Apache-2.0
-->

[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/omec-project/sdcore-helm-charts/badge)](https://scorecard.dev/viewer/?uri=github.com/omec-project/sdcore-helm-charts)

# SDCore Helm Charts
This repository contains Helm charts for deploying `Aether SD-Core` on Kubernetes.

Note that these Helm Charts can be used to deploy the Aether SD-Core. However,
the user should override the values.yaml file(s) to be able to properly deploy
all pods. One simple way to do so is by using the
[sdcore-5g-values.yaml](https://github.com/opennetworkinglab/aether-5gc/blob/master/roles/core/templates/sdcore-5g-values.yaml)
file from [Aether-Onramp](https://docs.aetherproject.org/master/onramp/overview.html).
Morever, some values need to be accordingly updated depending on the specific
deployment/setup as shown below.

## Example of usage with Aether OnRamp

It is strongly recommended to use [Aether-Onramp](https://docs.aetherproject.org/master/onramp/overview.html)
for the deployment of the `SD-Core` because `OnRamp`, besides deploying the
`SD-Core`, it also takes care of the networking required for the packets to be
forwarded across the 5GC.


```diff
diff --git a/roles/core/templates/sdcore-5g-values.yaml b/roles/core/templates/sdcore-5g-values.yaml
index defb44a..bcd9f4b 100644
--- a/roles/core/templates/sdcore-5g-values.yaml
+++ b/roles/core/templates/sdcore-5g-values.yaml
@@ -56,7 +56,7 @@ omec-control-plane:
     sctplb:
       deploy: true # If enabled then deploy sctp pod
       ngapp:
-        externalIp: {{ core.amf.ip }}
+        externalIp: <IP-address-for-N2-interface>
         port: 38412

     upfadapter:
@@ -110,7 +110,7 @@ omec-sub-provision:
       cfgFiles:
         simapp.yaml:
           configuration:
-            provision-network-slice: {{ core.standalone | string }} # if enabled, Device Groups & Slices configure by simapp
+            provision-network-slice: true # if enabled, Device Groups & Slices configure by simapp
             sub-provision-endpt:
               addr: webui.aether-5gc.svc.cluster.local  # subscriber configuation endpoint.
             # sub-proxy-endpt: # used if subscriber proxy is enabled in the ROC.
@@ -315,20 +315,20 @@ omec-user-plane:
       hugepage:
         enabled: false    # Should be enabled if DPDK is enabled
       routes:
-        - to: {{ ansible_default_ipv4.address }}
+        - to: <your-host-IP> # Host where the UPF pod will be deployed
           via: 169.254.1.1
       enb:
-        subnet: {{ ran_subnet }} # Subnet for the gNB network
+        subnet: <the-ran-subnet-to-use> # Subnet for the gNB network
       access:
         ipam: static
         cniPlugin: macvlan  # Can be any other plugin. Dictates how IP address are assigned
-        iface: {{ core.data_iface }}
+        iface: <interface-for-N3-interface>
         gateway: 192.168.252.1
         ip: 192.168.252.3/24
       core:
         ipam: static
         cniPlugin: macvlan  # Can be any other plugin. Dictates how IP address are assigned
-        iface: {{ core.data_iface }}
+        iface: <interface-for-N6-interface>
         gateway: 192.168.250.1
         ip: 192.168.250.3/24
       cfgFiles:
```
