{{- /*

# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: LicenseRef-ONF-Member-Only-1.0

*/ -}}

{{/*
Renders a set of standardised labels
*/}}
{{- define "5g-control-plane.metadata_labels" -}}
{{- $application := index . 0 -}}
{{- $context := index . 1 -}}
release: {{ $context.Release.Name }}
app: {{ $application }}
{{- end -}}

{{/*
Render the given template.
*/}}
{{- define "5g-control-plane.template" -}}
{{- $name := index . 0 -}}
{{- $context := index . 1 -}}
{{- $last := base $context.Template.Name }}
{{- $wtf := $context.Template.Name | replace $last $name -}}
{{ include $wtf $context }}
{{- end -}}

{{/*
Render ServiceAccount, Role, and RoleBinding required for kubernetes-entrypoint.
*/}}
{{- define "5g-control-plane.service_account" -}}
{{- $context := index . 1 -}}
{{- $saName := index . 0 -}}
{{- $saNamespace := $context.Release.Namespace }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ $saName }}
  namespace: {{ $saNamespace }}
  labels:
{{ tuple $saName $context | include "5g-control-plane.metadata_labels" | indent 4 }}
---
{{- if semverCompare ">=1.16-0" $context.Capabilities.KubeVersion.GitVersion }}
apiVersion: rbac.authorization.k8s.io/v1
{{- else }}
apiVersion: rbac.authorization.k8s.io/v1beta1
{{- end }}
kind: RoleBinding
metadata:
  name: {{ $saName }}
  namespace: {{ $saNamespace }}
  labels:
{{ tuple $saName $context | include "5g-control-plane.metadata_labels" | indent 4 }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: {{ $saName }}
subjects:
  - kind: ServiceAccount
    name: {{ $saName }}
    namespace: {{ $saNamespace }}
---
{{- if semverCompare ">=1.16-0" $context.Capabilities.KubeVersion.GitVersion }}
apiVersion: rbac.authorization.k8s.io/v1
{{- else }}
apiVersion: rbac.authorization.k8s.io/v1beta1
{{- end }}
kind: Role
metadata:
  name: {{ $saName }}
  namespace: {{ $saNamespace }}
  labels:
{{ tuple $saName $context | include "5g-control-plane.metadata_labels" | indent 4 }}
rules:
  - apiGroups:
      - ""
      - extensions
      - batch
      - apps
    verbs:
      - get
      - list
      - patch
    resources:
      - statefulsets
      - daemonsets
      - jobs
      - pods
      - services
      - endpoints
      - configmaps
{{- end -}}

{{/*
Render init container for coredump.
*/}}
{{- define "5g-control-plane.coredump_init" -}}
{{- $pod := index . 0 -}}
{{- $context := index . 1 -}}
- name: {{ $pod }}-coredump-init
  image: {{ $context.Values.images.tags.init | quote }}
  imagePullPolicy: {{ $context.Values.images.pullPolicy }}
  securityContext:
    privileged: true
    runAsUser: 0
  command: ["bash", "-xc"]
  args:
    - echo '/tmp/coredump/core.%h.%e.%t' > /mnt/host-rootfs/proc/sys/kernel/core_pattern
  volumeMounts:
    - name: host-rootfs
      mountPath: /mnt/host-rootfs
{{- end -}}
