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
Moreover, some values need to be accordingly updated depending on the specific
deployment/setup as shown below.

For the 5G control-plane chart, the shared CA private key is stored in a namespace Secret by default so leaf certificates can be regenerated across upgrades. In environments with tighter Secret-access requirements, set `5g-control-plane.config.certs.sharedCA.existingPrivateSecret` to a pre-created Secret containing non-empty `ca.crt` and `ca.key`, and restrict read access to that Secret. When this option is set, the chart now fails fast if that Secret is missing or incomplete instead of generating a replacement CA. Because the chart must read that CA private key at render time to sign the leaf certificates, this option requires rendering with cluster access; offline `helm template` without access to that Secret is not supported. If your cluster DNS domain is not `cluster.local`, set `5g-control-plane.config.certs.clusterDomain` accordingly or to an empty string to omit the fully-qualified service SAN. You can tune `5g-control-plane.config.certs.leafValidityDays` and `5g-control-plane.config.certs.clusterDomain` to affect newly rendered leaf certificates, and the chart will reissue leaf Secrets when those inputs change. `5g-control-plane.config.certs.sharedCA.validityDays` only affects newly generated CAs, so changing it does not automatically rotate an existing shared CA Secret. You can also set `5g-control-plane.config.certs.includeSystemRootBundle=false` if you want the generated CA bundle to contain only the shared CA instead of roots copied from the init image.

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
