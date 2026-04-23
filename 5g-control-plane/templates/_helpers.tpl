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
Shared public CA secret name.
*/}}
{{- define "5g-control-plane.shared-ca-secret-name" -}}
{{- printf "%s-ca" (include "5g-control-plane.name" .) -}}
{{- end -}}

{{/*
Shared private CA secret name.
*/}}
{{- define "5g-control-plane.shared-ca-private-secret-name" -}}
{{- $config := get .Values "config" | default dict -}}
{{- $certsConfig := get $config "certs" | default dict -}}
{{- $sharedCaConfig := get $certsConfig "sharedCA" | default dict -}}
{{- $existingPrivateSecret := get $sharedCaConfig "existingPrivateSecret" -}}
{{- default (printf "%s-ca-private" (include "5g-control-plane.name" .)) $existingPrivateSecret -}}
{{- end -}}

{{/*
Whether the chart should manage the shared private CA Secret.
*/}}
{{- define "5g-control-plane.manage-shared-ca-private-secret" -}}
{{- $config := get .Values "config" | default dict -}}
{{- $certsConfig := get $config "certs" | default dict -}}
{{- $sharedCaConfig := get $certsConfig "sharedCA" | default dict -}}
{{- if get $sharedCaConfig "existingPrivateSecret" -}}
false
{{- else -}}
true
{{- end -}}
{{- end -}}

{{/*
Cluster DNS domain to include in service certificate SANs. Empty omits the FQDN SAN.
*/}}
{{- define "5g-control-plane.cluster-domain" -}}
{{- $config := get .Values "config" | default dict -}}
{{- $certsConfig := get $config "certs" | default dict -}}
{{- if hasKey $certsConfig "clusterDomain" -}}
{{- get $certsConfig "clusterDomain" -}}
{{- else -}}
cluster.local
{{- end -}}
{{- end -}}

{{/*
Shared CA certificate validity in days.
*/}}
{{- define "5g-control-plane.shared-ca-validity-days" -}}
{{- $config := get .Values "config" | default dict -}}
{{- $certsConfig := get $config "certs" | default dict -}}
{{- $sharedCaConfig := get $certsConfig "sharedCA" | default dict -}}
{{- get $sharedCaConfig "validityDays" | default 365 | int -}}
{{- end -}}

{{/*
Leaf certificate validity in days.
*/}}
{{- define "5g-control-plane.leaf-cert-validity-days" -}}
{{- $config := get .Values "config" | default dict -}}
{{- $certsConfig := get $config "certs" | default dict -}}
{{- get $certsConfig "leafValidityDays" | default 365 | int -}}
{{- end -}}

{{/*
Whether the init container should append system roots from its own image.
*/}}
{{- define "5g-control-plane.include-system-root-bundle" -}}
{{- $config := get .Values "config" | default dict -}}
{{- $certsConfig := get $config "certs" | default dict -}}
{{- if hasKey $certsConfig "includeSystemRootBundle" -}}
{{- get $certsConfig "includeSystemRootBundle" -}}
{{- else -}}
true
{{- end -}}
{{- end -}}

{{/*
Annotation key used to mark leaf cert secrets with the shared CA checksum.
*/}}
{{- define "5g-control-plane.shared-ca-checksum-annotation" -}}
sdcore.omec-project.org/shared-ca-sha256
{{- end -}}

{{/*
Annotation key used to mark leaf cert secrets with the leaf generation inputs checksum.
*/}}
{{- define "5g-control-plane.leaf-cert-inputs-checksum-annotation" -}}
sdcore.omec-project.org/leaf-cert-inputs-sha256
{{- end -}}

{{/*
Ensure internal render cache exists.
*/}}
{{- define "5g-control-plane.ensure-render-cache" -}}
{{- $context := . -}}
{{- if not (hasKey $context.Values "_sdcoreInternal") -}}
{{- $_ := set $context.Values "_sdcoreInternal" (dict) -}}
{{- end -}}
{{- end -}}

{{/*
Compute the desired shared CA once per render and cache it.
*/}}
{{- define "5g-control-plane.ensure-shared-ca" -}}
{{- $context := . -}}
{{- include "5g-control-plane.ensure-render-cache" $context -}}
{{- $cache := index $context.Values "_sdcoreInternal" -}}
{{- if not (hasKey $cache "sharedCa") -}}
{{- $privateCaName := include "5g-control-plane.shared-ca-private-secret-name" $context -}}
{{- $managePrivateCaSecret := eq (include "5g-control-plane.manage-shared-ca-private-secret" $context | trim) "true" -}}
{{- $sharedCaValidityDays := include "5g-control-plane.shared-ca-validity-days" $context | int -}}
{{- $existingCaSecret := lookup "v1" "Secret" $context.Release.Namespace $privateCaName -}}
{{- $caCrt := "" -}}
{{- $caKey := "" -}}
{{- if and (not $managePrivateCaSecret) (not $existingCaSecret) -}}
{{- fail (printf "existing private CA Secret %q was configured but not found" $privateCaName) -}}
{{- end -}}
{{- if $existingCaSecret -}}
{{- $hasCaCrt := hasKey $existingCaSecret.data "ca.crt" -}}
{{- $hasCaKey := hasKey $existingCaSecret.data "ca.key" -}}
{{- if ne $hasCaCrt $hasCaKey -}}
{{- fail (printf "existing Secret %q must contain both ca.crt and ca.key or neither" $privateCaName) -}}
{{- end -}}
{{- if and $hasCaCrt $hasCaKey -}}
{{- $caCrt = index $existingCaSecret.data "ca.crt" | default "" | b64dec -}}
{{- $caKey = index $existingCaSecret.data "ca.key" | default "" | b64dec -}}
{{- if or (eq $caCrt "") (eq $caKey "") -}}
{{- fail (printf "existing Secret %q contains empty ca.crt or ca.key data" $privateCaName) -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- if and (not $managePrivateCaSecret) (or (eq $caCrt "") (eq $caKey "")) -}}
{{- fail (printf "existing private CA Secret %q must contain non-empty ca.crt and ca.key data" $privateCaName) -}}
{{- end -}}
{{- $ca := "" -}}
{{- if and $caCrt $caKey -}}
{{- $ca = buildCustomCert $caCrt $caKey -}}
{{- else -}}
{{- $ca = genCA $privateCaName $sharedCaValidityDays -}}
{{- end -}}
{{- $_ := set $cache "sharedCa" (dict "object" $ca "cert" $ca.Cert "key" $ca.Key "checksum" ($ca.Cert | sha256sum)) -}}
{{- end -}}
{{- end -}}

{{/*
Return the desired shared CA certificate PEM.
*/}}
{{- define "5g-control-plane.shared-ca-cert" -}}
{{- $context := . -}}
{{- include "5g-control-plane.ensure-shared-ca" $context -}}
{{- $cache := index $context.Values "_sdcoreInternal" -}}
{{- $sharedCa := index $cache "sharedCa" -}}
{{- index $sharedCa "cert" -}}
{{- end -}}

{{/*
Return the desired shared CA private key PEM.
*/}}
{{- define "5g-control-plane.shared-ca-key" -}}
{{- $context := . -}}
{{- include "5g-control-plane.ensure-shared-ca" $context -}}
{{- $cache := index $context.Values "_sdcoreInternal" -}}
{{- $sharedCa := index $cache "sharedCa" -}}
{{- index $sharedCa "key" -}}
{{- end -}}

{{/*
Return the desired shared CA checksum.
*/}}
{{- define "5g-control-plane.shared-ca-checksum" -}}
{{- $context := . -}}
{{- include "5g-control-plane.ensure-shared-ca" $context -}}
{{- $cache := index $context.Values "_sdcoreInternal" -}}
{{- $sharedCa := index $cache "sharedCa" -}}
{{- index $sharedCa "checksum" -}}
{{- end -}}

{{/*
Compute desired leaf certificate material once per render and cache it.
*/}}
{{- define "5g-control-plane.ensure-leaf-cert" -}}
{{- $context := .context -}}
{{- $name := .name -}}
{{- include "5g-control-plane.ensure-shared-ca" $context -}}
{{- $cache := index $context.Values "_sdcoreInternal" -}}
{{- if not (hasKey $cache "leafCerts") -}}
{{- $_ := set $cache "leafCerts" (dict) -}}
{{- end -}}
{{- $leafCerts := index $cache "leafCerts" -}}
{{- if not (hasKey $leafCerts $name) -}}
{{- $sharedCa := index $cache "sharedCa" -}}
{{- $ca := index $sharedCa "object" -}}
{{- $caChecksum := index $sharedCa "checksum" -}}
{{- $leafValidityDays := include "5g-control-plane.leaf-cert-validity-days" $context | int -}}
{{- $namespace := $context.Release.Namespace -}}
{{- $clusterDomain := include "5g-control-plane.cluster-domain" $context | trim -}}
{{- $leafInputsChecksum := printf "%s|%s|%s|%d" $name $namespace $clusterDomain $leafValidityDays | sha256sum -}}
{{- $secretName := printf "%s-certs" $name -}}
{{- $existingSecret := lookup "v1" "Secret" $namespace $secretName -}}
{{- $tlsCrt := "" -}}
{{- $tlsKey := "" -}}
{{- if $existingSecret -}}
{{- $hasTlsCrt := hasKey $existingSecret.data "tls.crt" -}}
{{- $hasTlsKey := hasKey $existingSecret.data "tls.key" -}}
{{- if ne $hasTlsCrt $hasTlsKey -}}
{{- fail (printf "existing Secret %q must contain both tls.crt and tls.key or neither" $secretName) -}}
{{- end -}}
{{- if and $hasTlsCrt $hasTlsKey -}}
{{- $tlsCrt = index $existingSecret.data "tls.crt" | default "" -}}
{{- $tlsKey = index $existingSecret.data "tls.key" | default "" -}}
{{- $annotations := default dict $existingSecret.metadata.annotations -}}
{{- $existingCaChecksum := index $annotations (include "5g-control-plane.shared-ca-checksum-annotation" $context) | default "" -}}
{{- $existingLeafInputsChecksum := index $annotations (include "5g-control-plane.leaf-cert-inputs-checksum-annotation" $context) | default "" -}}
{{- if or (eq $tlsCrt "") (eq $tlsKey "") -}}
{{- fail (printf "existing Secret %q contains empty tls.crt or tls.key data" $secretName) -}}
{{- end -}}
{{- if or (ne $existingCaChecksum $caChecksum) (ne $existingLeafInputsChecksum $leafInputsChecksum) -}}
{{- $tlsCrt = "" -}}
{{- $tlsKey = "" -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- if and $tlsCrt $tlsKey -}}
{{- $_ := set $leafCerts $name (dict "data" (printf "tls.crt: %s\ntls.key: %s" $tlsCrt $tlsKey) "checksum" (printf "%s%s" $tlsCrt $tlsKey | sha256sum)) -}}
{{- else -}}
{{- $altNames := list
  $name
  ( printf "%s.%s" $name $namespace )
  ( printf "%s.%s.svc" $name $namespace ) -}}
{{- if $clusterDomain -}}
{{- $altNames = append $altNames (printf "%s.%s.svc.%s" $name $namespace $clusterDomain) -}}
{{- end -}}
{{- $cert := genSignedCert $name nil $altNames $leafValidityDays $ca -}}
{{- $tlsCrt = $cert.Cert | b64enc -}}
{{- $tlsKey = $cert.Key | b64enc -}}
{{- $_ := set $leafCerts $name (dict "data" (printf "tls.crt: %s\ntls.key: %s" $tlsCrt $tlsKey) "checksum" (printf "%s%s" $tlsCrt $tlsKey | sha256sum)) -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return desired leaf certificate input checksum.
*/}}
{{- define "5g-control-plane.leaf-cert-inputs-checksum" -}}
{{- $context := .context -}}
{{- $name := .name -}}
{{- $namespace := $context.Release.Namespace -}}
{{- $clusterDomain := include "5g-control-plane.cluster-domain" $context | trim -}}
{{- $leafValidityDays := include "5g-control-plane.leaf-cert-validity-days" $context | int -}}
{{- printf "%s|%s|%s|%d" $name $namespace $clusterDomain $leafValidityDays | sha256sum -}}
{{- end -}}

{{/*
Return desired leaf certificate Secret data.
*/}}
{{- define "5g-control-plane.gen-certs" -}}
{{- $context := .context -}}
{{- $name := .name -}}
{{- include "5g-control-plane.ensure-leaf-cert" (dict "context" $context "name" $name) -}}
{{- $cache := index $context.Values "_sdcoreInternal" -}}
{{- $leafCerts := index $cache "leafCerts" -}}
{{- $leafCert := index $leafCerts $name -}}
{{- index $leafCert "data" -}}
{{- end -}}

{{/*
Return desired leaf certificate checksum.
*/}}
{{- define "5g-control-plane.leaf-cert-checksum" -}}
{{- $context := .context -}}
{{- $name := .name -}}
{{- include "5g-control-plane.ensure-leaf-cert" (dict "context" $context "name" $name) -}}
{{- $cache := index $context.Values "_sdcoreInternal" -}}
{{- $leafCerts := index $cache "leafCerts" -}}
{{- $leafCert := index $leafCerts $name -}}
{{- index $leafCert "checksum" -}}
{{- end -}}

{{/*
Render init container that builds a CA bundle with system roots plus the shared CA.
*/}}
{{- define "5g-control-plane.certs_init" -}}
{{- $pod := index . 0 -}}
{{- $context := index . 1 -}}
{{- $includeSystemRootBundle := eq (include "5g-control-plane.include-system-root-bundle" $context | trim) "true" -}}
- name: {{ $pod }}-certs-init
  image: {{ $context.Values.images.repository }}{{ $context.Values.images.tags.init }}
  imagePullPolicy: {{ $context.Values.images.pullPolicy }}
  command: ["sh", "-ec"]
  args:
    - |
      set -e
      umask 077
{{ if $includeSystemRootBundle }}
      root_bundle=""
      for candidate in /etc/ssl/certs/ca-certificates.crt /etc/pki/tls/certs/ca-bundle.crt /etc/ssl/cert.pem; do
        if [ -f "$candidate" ]; then
          root_bundle="$candidate"
          break
        fi
      done
{{ end }}
      cp /certs-src/tls.crt /work/tls.crt
      cp /certs-src/tls.key /work/tls.key
      cp /certs-src/ca.crt /work/ca.crt
{{ if $includeSystemRootBundle }}
      if [ -n "$root_bundle" ]; then
        cat "$root_bundle" /certs-src/ca.crt > /work/ca-bundle.crt
      else
        cp /certs-src/ca.crt /work/ca-bundle.crt
      fi
{{ else }}
      cp /certs-src/ca.crt /work/ca-bundle.crt
{{ end }}
        chmod 0644 /work/tls.crt /work/ca.crt /work/ca-bundle.crt
        chmod 0644 /work/tls.key
  volumeMounts:
    - name: certs-src
      mountPath: /certs-src
      readOnly: true
    - name: certs
      mountPath: /work
{{- end -}}

{{/*
Render pod template annotations that trigger a rollout when mounted cert sources change.
*/}}
{{- define "5g-control-plane.certs_pod_annotations" -}}
{{- $name := index . 0 -}}
{{- $context := index . 1 -}}
{{- $sharedCaChecksum := include "5g-control-plane.shared-ca-checksum" $context | trim -}}
{{- $leafSecretName := printf "%s-certs" $name -}}
{{- $leafChecksum := include "5g-control-plane.leaf-cert-checksum" (dict "context" $context "name" $name) | trim -}}
checksum/sdcore-shared-ca: {{ $sharedCaChecksum | quote }}
checksum/{{ $leafSecretName }}: {{ $leafChecksum | quote }}
{{- end -}}
