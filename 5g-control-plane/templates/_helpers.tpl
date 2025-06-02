{{- /*

# Copyright 2020-present Open Networking Foundation
#
# SPDX-License-Identifier: Apache-2.0

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

{{/*
Expand the name of the chart.
*/}}
{{- define "5g-control-plane.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Generate certificates for 5GC-CP
*/}}
{{- define "5g-control-plane.gen-certs" -}}
{{- $altNames := list ( printf "%s.%s" (include "5g-control-plane.name" .) .Release.Namespace ) ( printf "%s.%s.svc" (include "5g-control-plane.name" .) .Release.Namespace ) -}}
{{- $ca := genCA "5g-control-plane-ca" 365 -}}
{{- $cert := genSignedCert ( include "5g-control-plane.name" . ) nil $altNames 365 $ca -}}
tls.crt: {{ $cert.Cert | b64enc }}
tls.key: {{ $cert.Key | b64enc }}
{{- end -}}

{{/*
Render confidential container annotations
*/}}
{{- define "5g-control-plane.confidential_annotations" -}}
{{- if or .Values.confidentialContainers.enabled .Values.confidentialContainers.annotation.enabled }}
io.containerd.cri.runtime-handler: kata-qemu
{{- if .Values.confidentialContainers.annotation.enabled }}
{{- if .Values.confidentialContainers.annotation.kernelParams }}
io.katacontainers.config.hypervisor.kernel_params: {{ .Values.confidentialContainers.annotation.kernelParams | quote }}
{{- else if .Values.confidentialContainers.attestation.kbsAddress }}
io.katacontainers.config.hypervisor.kernel_params: "agent.guest_components_rest_api=all agent.aa_kbc_params=cc_kbc::{{ .Values.confidentialContainers.attestation.kbsAddress }}"
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Render attestation init container
*/}}
{{- define "5g-control-plane.attestation_init" -}}
{{- if .Values.confidentialContainers.attestation.enabled }}
- name: init-attestation
  image: {{ .Values.images.repository }}{{ .Values.images.tags.attestation }}
  imagePullPolicy: {{ .Values.images.pullPolicy }}
  command: ["/bin/sh","-c"]
  args:
    - |
      echo "Starting attestation process...";
      timeout={{ .Values.confidentialContainers.attestation.timeout | default 300 }};
      elapsed=0;
      while [ $elapsed -lt $timeout ]; do
        if curl -s {{ .Values.confidentialContainers.attestation.attestationUrl }} | grep -iv "get token failed" | grep -iv "error" | grep -i token; then
          echo "ATTESTATION COMPLETED SUCCESSFULLY";
          exit 0;
        fi;
        echo "Attestation attempt failed, retrying...";
        sleep 5;
        elapsed=$((elapsed + 5));
      done;
      echo "ATTESTATION FAILED: Timeout after ${timeout} seconds";
      {{- if .Values.confidentialContainers.attestation.required }}
      exit 1;
      {{- else }}
      echo "Attestation not required, continuing...";
      exit 0;
      {{- end }}
{{- end }}
{{- end -}}
