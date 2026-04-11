#!/bin/bash

# Copyright 2026 Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0

{{- $accessResourceEnv := .Values.config.upf.access.resourceName | replace "." "_" | replace "/" "_" | replace "-" "_" | upper }}
{{- $coreResourceEnv := .Values.config.upf.core.resourceName | replace "." "_" | replace "/" "_" | replace "-" "_" | upper }}
{{- $upfConfig := index .Values.config.upf.cfgFiles "upf.jsonc" }}
{{- $upfMode := index $upfConfig "mode" }}

set -euo pipefail

bess_args=(bessd)
resolved_devices=()
allow_list=""

{{- if not .Values.config.upf.hugepage.enabled }}
bess_args+=(-m 0)
{{- end }}

{{- if or (eq $upfMode "af_packet") (eq $upfMode "af_xdp") }}
bess_args+=(--iova=va)
{{- end }}

bess_args+=(-f)

normalize_pci_addr() {
    local raw_device="$1"
    local domain bus slot function

    if [[ "$raw_device" =~ ^([[:xdigit:]]{4}|[[:xdigit:]]{8}):([[:xdigit:]]{2}):([[:xdigit:]]{2})\.([[:xdigit:]]{1,2})$ ]]; then
        domain="${BASH_REMATCH[1]}"
        bus="${BASH_REMATCH[2]}"
        slot="${BASH_REMATCH[3]}"
        function="${BASH_REMATCH[4]}"

        printf -v domain '%04x' "$((16#$domain))"
        printf -v bus '%02x' "$((16#$bus))"
        printf -v slot '%02x' "$((16#$slot))"
        printf -v function '%x' "$((16#$function))"

        printf '%s:%s:%s.%s' "$domain" "$bus" "$slot" "$function"
        return 0
    fi

    printf '%s' "$raw_device"
}

append_devices() {
    local raw_devices="$1"
    local device
    local -a parsed_devices=()

    if [[ -z "$raw_devices" ]]; then
        return
    fi

    IFS=',' read -r -a parsed_devices <<< "$raw_devices"
    for device in "${parsed_devices[@]}"; do
        device="${device//[[:space:]]/}"
        if [[ -z "$device" ]]; then
            continue
        fi

        resolved_devices+=("$(normalize_pci_addr "$device")")
    done
}

append_devices "${PCIDEVICE_{{ $accessResourceEnv }}:-}"
{{- if ne $accessResourceEnv $coreResourceEnv }}
append_devices "${PCIDEVICE_{{ $coreResourceEnv }}:-}"
{{- end }}

if [[ ${#resolved_devices[@]} -eq 0 ]]; then
{{- if .Values.config.upf.sriov.enabled }}
    echo "SR-IOV is enabled but no PCI devices were resolved for bessd startup" >&2
    exit 1
{{- else }}
    echo "Starting bessd without an allow-list" >&2
{{- end }}
else
    allow_list=$(IFS=,; echo "${resolved_devices[*]}")
    echo "Starting bessd with allow-list: ${resolved_devices[*]}" >&2
    bess_args+=("--allow=${allow_list}")
fi

bess_args+=(--grpc_url=0.0.0.0:10514)
exec "${bess_args[@]}"