<!-- SPDX-License-Identifier: Apache-2.0 -->
<!-- Copyright 2024-present Open Networking Foundation -->

PFCP Dump Examples
===================

This file contains example `values.yaml` snippets to enable the PFCP raw-dump feature for debugging parse errors in the `pfcp-agent` container.


## Use transient storage (emptyDir) — good for testing/local/dev

```yaml
upfDump:
  enabled: true
  dir: /var/log/upf/pfcp_dumps
  upfName: my-upf-instance
  maxBytes: 104857600  # 100 MiB total per-instance
  maxFiles: 1000
  toLog: false
  persistence:
    enabled: false
```

This will mount an `emptyDir` into the pod at `/var/log/upf/pfcp_dumps` and the runtime will prune files when the directory exceeds `maxBytes` or `maxFiles`.

## Use persistent storage (PVC) — for production/long-term capture

```yaml
upfDump:
  enabled: true
  dir: /var/log/upf/pfcp_dumps
  upfName: upf-01
  maxBytes: 1073741824  # 1 GiB
  maxFiles: 10000
  toLog: false
  persistence:
    enabled: true
    size: 10Gi
    storageClass: fast-ssd
```

This configuration will cause the chart to create a PersistentVolumeClaim named `<release>-pfcp-dump-pvc` and mount it into the `pfcp-agent` container at the configured `dir`.

Notes:

- `maxBytes` and `maxFiles` are enforced by the UPF process (pruning). Set either to `0` to disable that limit.
- `toLog=true` will also emit base64-encoded dumps to application logs — be careful in high-throughput environments.
