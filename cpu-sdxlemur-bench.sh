#!/bin/sh

PATH="/opt/bin:/opt/sbin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
export PATH

methods="int64 matrixprod"
timeout=30
threads=$(grep -c ^processor /proc/cpuinfo 2>/dev/null)
[ -z "$threads" ] || [ "$threads" -lt 1 ] 2>/dev/null && threads=1

# --- Detect Device, CPU, and Firmware Version on SDXLEMUR / Quectel Linux ----
detect_platform() {
    device=""
    cpu_model=""
    version=""

    if [ -f /etc/quectel-project-version ]; then
        proj_name=$(grep -m1 "^Project Name:" /etc/quectel-project-version 2>/dev/null | sed 's/^Project Name:[[:space:]]*//' | tr -d '\r[:space:]')
        proj_rev=$(grep -m1 "^Project Rev" /etc/quectel-project-version 2>/dev/null | sed 's/^Project Rev[[:space:]]*:[[:space:]]*//' | tr -d '\r[:space:]')
        branch_name=$(grep -m1 "^Branch[[:space:]]*Name:" /etc/quectel-project-version 2>/dev/null | sed 's/^Branch[[:space:]]*Name:[[:space:]]*//' | tr -d '\r[:space:]')

        case "$proj_name" in
            RM520N*) device="Quectel RM520N-GL" ;;
            RG501Q*) device="Quectel RG501Q-EU" ;;
            RM500Q*) device="Quectel RM500Q-GL" ;;
            RM502Q*) device="Quectel RM502Q-AE" ;;
            ?*)      device="Quectel ${proj_name%_*}" ;;
        esac

        case "$branch_name" in
            SDX6X*|SDX62*) cpu_model="Qualcomm SDX62" ;;
            SDX65*)        cpu_model="Qualcomm SDX65" ;;
            SDX55*)        cpu_model="Qualcomm SDX55" ;;
        esac

        if [ -n "$proj_rev" ]; then
            version=$(printf '%s' "$proj_rev" | cut -d'_' -f1)
        fi
    fi

    if [ -z "$device" ]; then
        if [ -f /tmp/sysinfo/model ]; then
            device=$(cat /tmp/sysinfo/model 2>/dev/null)
        elif [ -f /proc/device-tree/model ]; then
            device=$(tr -d '\0\r\n' < /proc/device-tree/model 2>/dev/null)
        else
            device=$(uname -n 2>/dev/null || echo "Unknown Device")
        fi
    fi

    if [ -z "$cpu_model" ]; then
        case "$(uname -n 2>/dev/null)" in
            sdxlemur*)   cpu_model="Qualcomm SDX62" ;;
            sdxprairie*) cpu_model="Qualcomm SDX55" ;;
            *)
                cpu_model=$(awk -F': ' '/^Hardware|^model name|^Processor/ {gsub(/\r/, "", $2); print $2; exit}' /proc/cpuinfo 2>/dev/null)
                [ -z "$cpu_model" ] && cpu_model="ARMv7 Cortex-A7"
                ;;
        esac
    fi

    if [ -z "$version" ]; then
        if [ -f /etc/os-release ] && grep -q OPENWRT_RELEASE /etc/os-release 2>/dev/null; then
            version=$(grep OPENWRT_RELEASE /etc/os-release | cut -d'"' -f2 | cut -d' ' -f1,2)
        else
            version="Linux $(uname -r 2>/dev/null)"
        fi
    fi
}

# --- Resolve or Bootstrap stress-ng (Alpine v3.22 armv7 musl bundle) ---------
ALPINE_DIR="/tmp/stress-ng-alpine"
STRESS_NG_CMD=""

resolve_stress_ng() {
    if command -v stress-ng >/dev/null 2>&1; then
        STRESS_NG_CMD="stress-ng"
        return 0
    fi

    if [ -x "$ALPINE_DIR/lib/ld-musl-armhf.so.1" ] && [ -x "$ALPINE_DIR/usr/bin/stress-ng" ]; then
        STRESS_NG_CMD="$ALPINE_DIR/lib/ld-musl-armhf.so.1 --library-path $ALPINE_DIR/lib:$ALPINE_DIR/usr/lib $ALPINE_DIR/usr/bin/stress-ng"
        return 0
    fi

    if [ -x "$ALPINE_DIR/lib/ld-musl-armhf.so.1" ] && [ -x "$ALPINE_DIR/stress-ng" ]; then
        STRESS_NG_CMD="$ALPINE_DIR/lib/ld-musl-armhf.so.1 --library-path $ALPINE_DIR/lib $ALPINE_DIR/stress-ng"
        return 0
    fi

    return 1
}

download_file() {
    _url="$1"
    _dst="$2"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL --connect-timeout 10 -o "$_dst" "$_url" 2>/dev/null
    elif command -v wget >/dev/null 2>&1; then
        wget -q -T 20 -O "$_dst" "$_url" 2>/dev/null
    else
        return 1
    fi
}

install_stress_ng_portable() {
    rm -rf "$ALPINE_DIR"
    mkdir -p "$ALPINE_DIR"

    # 1. Check for pre-pushed offline bundle in /tmp or current directory
    for _bundle in /tmp/stress-ng-armv7l.tar.gz ./stress-ng-armv7l.tar.gz; do
        if [ -f "$_bundle" ]; then
            echo "Found offline bundle: $_bundle"
            if gzip -dc "$_bundle" | tar -xf - -C "$ALPINE_DIR" 2>/dev/null; then
                chmod 755 "$ALPINE_DIR/lib/ld-musl-armhf.so.1" "$ALPINE_DIR/stress-ng" 2>/dev/null || true
                resolve_stress_ng && return 0
            fi
        fi
    done

    # 2. Download portable bundle from GitHub or Alpine Linux CDN (v3.22 armv7)
    echo "Downloading portable stress-ng (armv7l) to $ALPINE_DIR..."
    _gh_bundle="https://raw.githubusercontent.com/akorshun/cpu-wrt-bench/main/stress-ng-armv7l.tar.gz"
    if download_file "$_gh_bundle" "/tmp/stress-ng-armv7l.tar.gz"; then
        if gzip -dc "/tmp/stress-ng-armv7l.tar.gz" | tar -xf - -C "$ALPINE_DIR" 2>/dev/null; then
            rm -f "/tmp/stress-ng-armv7l.tar.gz"
            chmod 755 "$ALPINE_DIR/lib/ld-musl-armhf.so.1" "$ALPINE_DIR/stress-ng" 2>/dev/null || true
            resolve_stress_ng && return 0
        fi
        rm -f "/tmp/stress-ng-armv7l.tar.gz"
    fi

    _base_main="https://dl-cdn.alpinelinux.org/alpine/v3.22/main/armv7"
    _base_comm="https://dl-cdn.alpinelinux.org/alpine/v3.22/community/armv7"
    _apks="
        $_base_comm/stress-ng-0.18.08-r0.apk
        $_base_main/musl-1.2.5-r13.apk
        $_base_main/zlib-1.4-r0.apk
        $_base_main/libbsd-0.12.2-r0.apk
        $_base_main/libmd-1.1.0-r0.apk
        $_base_main/judy-1.0.5-r1.apk
        $_base_main/liblksctp-1.0.19-r5.apk
    "

    for _u in $_apks; do
        _fn="/tmp/$(basename "$_u")"
        if ! download_file "$_u" "$_fn"; then
            echo "Failed to download $_u"
            echo "If the modem is in IP Passthrough mode (no direct internet on modem),"
            echo "push stress-ng-armv7l.tar.gz to /tmp/ first."
            rm -f "$_fn"
            return 1
        fi
        gzip -dc "$_fn" 2>/dev/null | tar -xf - -C "$ALPINE_DIR" 2>/dev/null
        rm -f "$_fn"
    done

    chmod 755 "$ALPINE_DIR/lib/ld-musl-armhf.so.1" "$ALPINE_DIR/usr/bin/stress-ng" 2>/dev/null || true
    resolve_stress_ng
}

detect_platform

if ! resolve_stress_ng; then
    echo "stress-ng is not installed."
    install_stress_ng_portable || {
        echo "Failed to prepare stress-ng"
        exit 1
    }
fi

echo "== CPU SDXLEMUR / Modem Benchmark =="
echo "https://github.com/akorshun/cpu-wrt-bench"
echo
echo "Device:        $device"
echo "CPU:           $cpu_model"
echo "Version:       $version"
echo "CPU Threads:   $threads"
echo
echo "Please wait 2 minutes..."
echo

echo "[1 thread]"
echo "Method       Bogo Ops/s (real time)"
for method in $methods; do
    output=$($STRESS_NG_CMD --cpu 1 --cpu-method "$method" --metrics-brief --timeout ${timeout}s 2>&1)
    bogo=$(printf '%s\n' "$output" | grep -E "stress-ng:.*metrc:" | grep "cpu" | awk '{print $(NF-1)}')
    printf "%-12s %s\n" "$method" "${bogo:-n/s}"
    eval "${method}_1thread=${bogo:-n/s}"
done

echo

echo "[${threads} threads]"
echo "Method       Bogo Ops/s (real time)"
for method in $methods; do
    output=$($STRESS_NG_CMD --cpu "$threads" --cpu-method "$method" --metrics-brief --timeout ${timeout}s 2>&1)
    bogo=$(printf '%s\n' "$output" | grep -E "stress-ng:.*metrc:" | grep "cpu" | awk '{print $(NF-1)}')
    printf "%-12s %s\n" "$method" "${bogo:-n/s}"
    eval "${method}_allthreads=${bogo:-n/s}"
done

echo
echo "Markdown Table Row:"
printf "| %-26s | %-23s | %-32s | %-12s | %-16s | %-20s | %-19s | %-24s |\n" \
  "$device" "$cpu_model" "$version" "$threads" \
  "$int64_1thread" "$matrixprod_1thread" \
  "$int64_allthreads" "$matrixprod_allthreads"
