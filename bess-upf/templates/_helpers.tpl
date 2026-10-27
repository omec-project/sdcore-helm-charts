{{- /*

# Copyright (c) 2026 Intel Corporation
# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

*/ -}}

{{/*
Renders a set of standardised labels.
*/}}
{{- define "omec-user-plane.metadata_labels" -}}
{{- $application := index . 0 -}}
{{- $context := index . 1 -}}
release: {{ $context.Release.Name }}
app: {{ $application }}
{{- end -}}

{{/*
Render the given template.
*/}}
{{- define "omec-user-plane.template" -}}
{{- $name := index . 0 -}}
{{- $context := index . 1 -}}
{{- $last := base $context.Template.Name }}
{{- $wtf := $context.Template.Name | replace $last $name -}}
{{ include $wtf $context }}
{{- end -}}

{{/*
Render init container for coredump.
*/}}
{{- define "omec-user-plane.coredump_init" -}}
{{- $pod := index . 0 -}}
{{- $context := index . 1 -}}
- name: {{ $pod }}-coredump-init
  image: {{ $context.Values.images.tags.tools | quote }}
  imagePullPolicy: {{ $context.Values.images.pullPolicy }}
  securityContext:
    privileged: true
    runAsUser: 0
  command: ["sh", "-xc"]
  args:
    - echo '/tmp/coredump/core.%h.%e.%t' > /mnt/host-rootfs/proc/sys/kernel/core_pattern
  volumeMounts:
    - name: host-rootfs
      mountPath: /mnt/host-rootfs
{{- end -}}

{{/*
Render SR-IOV CNI init container. Use mode "init-net" for the init-net DaemonSet,
or "sriov-device-plugin" for the sriov-device-plugin initContainer.
*/}}
{{- define "omec-user-plane.sriov_init_container" -}}
{{- $mode := .mode | default "sriov-device-plugin" -}}
- name: init-sriov-plugin
  image: {{ .Values.images.repository }}{{ .Values.images.tags.sriov }}
  imagePullPolicy: {{ .Values.images.pullPolicy }}
  command: ["bash", "-c"]
{{- if eq $mode "init-net" }}
{{- $commands := list }}
{{- range (list "vfioveth" "jq" "static") }}
{{- $commands = append $commands (printf "yes | cp /tmp/cni/bin/%s /host/opt/cni/bin/" .) }}
{{- end }}
{{- range (list "vfioveth" "static") }}
{{- $commands = append $commands (printf "chmod +x /host/opt/cni/bin/%s" .) }}
{{- end }}
{{- $commands = append $commands "trap : TERM INT" }}
{{- $commands = append $commands "sleep infinity & wait" }}
  args:
    - {{ join "; " $commands | quote }}
{{- else }}
{{- $commands := list }}
{{- range (list "sriov" "vfioveth" "jq" "static" "dhcp") }}
{{- $commands = append $commands (printf "cp /tmp/cni/bin/%s /host/opt/cni/bin/" .) }}
{{- end }}
{{- range (list "vfioveth") }}
{{- $commands = append $commands (printf "chmod +x /host/opt/cni/bin/%s" .) }}
{{- end }}
  args:
    - {{ join "; " $commands | quote }}
{{- end }}
  volumeMounts:
    - name: cni-bin
      mountPath: /host/opt/cni/bin
{{- end -}}

{{/*
Render a Service's metadata and the spec up to its ports: labels, annotations,
type, external IP and selector. The caller adds the ports.
Usage: {{ tuple "upf-http" "upf" . | include "omec-user-plane.service_head" }}
*/}}
{{- define "omec-user-plane.service_head" -}}
{{- $name := index . 0 -}}
{{- $app := index . 1 -}}
{{- $context := index . 2 -}}
metadata:
  name: {{ $name }}
  labels:
{{ tuple $app $context | include "omec-user-plane.metadata_labels" | indent 4 }}
{{- with $context.Values.service.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
{{- end }}
spec:
  type: {{ $context.Values.service.type }}
{{- if $context.Values.service.externalIp }}
  externalIPs:
    - {{ $context.Values.service.externalIp }}
{{- end }}
  selector:
{{ tuple $app $context | include "omec-user-plane.metadata_labels" | indent 4 }}
{{- end -}}

{{/*
Render one port of the UPF Services. The nodePort is only set when the Service
is of type NodePort.
Usage: {{- tuple "pfcp" "UDP" 8805 .Values.service.nodePort . | include "omec-user-plane.service_port" | nindent 2 }}
*/}}
{{- define "omec-user-plane.service_port" -}}
{{- $name := index . 0 -}}
{{- $protocol := index . 1 -}}
{{- $port := index . 2 -}}
{{- $nodePort := index . 3 -}}
{{- $context := index . 4 -}}
- name: {{ $name }}
  protocol: {{ $protocol }}
  port: {{ $port }}
{{- if and (eq $context.Values.service.type "NodePort") $nodePort }}
  nodePort: {{ $nodePort }}
{{- end }}
{{- end -}}
