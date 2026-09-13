#!/bin/bash
#
# device-model.sh - gibt "Hersteller Modell" der aktuellen Maschine aus.
#
# Warum ein eigenes Skript?
#   Der Startup-Banner (custom/startupcode.zsh) nutzte
#   "hostnamectl --json short | jq ...". hostnamectl gehoert zu systemd,
#   auf macOS gibt es das nicht. Damit derselbe Banner auf Fedora UND
#   macOS laeuft, steckt die OS-Weiche hier drin statt in der zsh-Config.
#
# Warum Cache?
#   Die Abfrage kostet je nach Geraet ein paar hundert Millisekunden
#   (system_profiler auf macOS). Die Hardware aendert sich zwischen zwei
#   Shell-Starts aber nie - also einmal ermitteln, danach aus
#   ~/.cache/device-model lesen.
#
# Benutzung:
#   device-model.sh             # aus Cache, sonst ermitteln + cachen
#   device-model.sh --refresh   # Cache verwerfen und neu ermitteln
#   device-model.sh --no-cache  # ermitteln, Cache weder lesen noch schreiben
#
# Kompatibilitaet: bash 3.2 (macOS liefert nichts Neueres aus), daher
# kein ${var,,}, kein mapfile, keine assoziativen Arrays.

set -u

cache_file="${XDG_CACHE_HOME:-$HOME/.cache}/device-model"
use_cache=1
refresh=0

case "${1:-}" in
    --refresh)  refresh=1 ;;
    --no-cache) use_cache=0 ;;
    -h|--help)
        sed -n '3,20p' "$0" | sed 's/^#[[:space:]]\{0,1\}//'
        exit 0
        ;;
    "") ;;
    *)
        printf 'device-model.sh: unbekannte Option: %s\n' "$1" >&2
        exit 2
        ;;
esac

# Platzhalter, die viele Mainboards statt echter Werte melden.
is_junk() {
    case "$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')" in
        ""|"none"|"unknown"|"n/a"|"not specified"|"not applicable" \
        |"default string"|"to be filled by o.e.m."|"o.e.m." \
        |"system product name"|"system manufacturer"|"system version")
            return 0
            ;;
    esac
    return 1
}

# Whitespace am Rand weg (DMI-Dateien haben gern ein Leerzeichen zu viel).
trim() {
    printf '%s' "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

# Hersteller + Modell zusammensetzen. Wenn das Modell den Hersteller schon
# enthaelt ("Lenovo ThinkPad X1"), wird er nicht doppelt vorangestellt.
join_vendor_model() {
    vendor="$(trim "${1:-}")"
    model="$(trim "${2:-}")"

    is_junk "$model" && model=""
    is_junk "$vendor" && vendor=""

    [ -z "$model" ] && { printf '%s' "$vendor"; return; }
    [ -z "$vendor" ] && { printf '%s' "$model"; return; }

    model_lc="$(printf '%s' "$model" | tr '[:upper:]' '[:lower:]')"
    vendor_lc="$(printf '%s' "$vendor" | tr '[:upper:]' '[:lower:]')"
    case "$model_lc" in
        "$vendor_lc"*)
            printf '%s' "$model"
            return
            ;;
    esac

    printf '%s %s' "$vendor" "$model"
}

detect_darwin() {
    name="$(system_profiler SPHardwareDataType 2>/dev/null \
        | awk -F': ' '/Model Name:/ {print $2; exit}')"
    ident="$(sysctl -n hw.model 2>/dev/null)"

    # "MacBook Pro" allein unterscheidet keine zwei Macs - die Model-ID
    # (Mac16,1) macht die Ausgabe so spezifisch wie unter Linux.
    if [ -n "$name" ] && [ -n "$ident" ]; then
        printf 'Apple %s (%s)' "$name" "$ident"
    elif [ -n "$name" ]; then
        printf 'Apple %s' "$name"
    elif [ -n "$ident" ]; then
        printf 'Apple %s' "$ident"
    fi
}

detect_linux() {
    # 1. systemd - liest selbst DMI/Devicetree und kennt auch VM-Hosts.
    #    Textausgabe statt "--json short | jq", damit kein jq noetig ist.
    if command -v hostnamectl >/dev/null 2>&1; then
        info="$(hostnamectl 2>/dev/null)"
        hc_vendor="$(printf '%s\n' "$info" \
            | sed -n 's/^[[:space:]]*Hardware Vendor:[[:space:]]*//p' | head -n1)"
        hc_model="$(printf '%s\n' "$info" \
            | sed -n 's/^[[:space:]]*Hardware Model:[[:space:]]*//p' | head -n1)"
        result="$(join_vendor_model "$hc_vendor" "$hc_model")"
        [ -n "$result" ] && { printf '%s' "$result"; return; }
    fi

    # 2. DMI direkt - funktioniert ohne systemd (Container, Minimal-Images).
    if [ -r /sys/class/dmi/id/product_name ]; then
        result="$(join_vendor_model \
            "$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null)" \
            "$(cat /sys/class/dmi/id/product_name 2>/dev/null)")"
        [ -n "$result" ] && { printf '%s' "$result"; return; }
    fi

    # 3. Devicetree - ARM-Boards (Raspberry Pi) haben kein DMI.
    for dt in /sys/firmware/devicetree/base/model /proc/device-tree/model; do
        if [ -r "$dt" ]; then
            # Devicetree-Strings sind NUL-terminiert.
            result="$(tr -d '\0' < "$dt")"
            is_junk "$result" || { printf '%s' "$result"; return; }
        fi
    done
}

detect() {
    case "$(uname -s)" in
        Darwin) detect_darwin ;;
        Linux)  detect_linux ;;
    esac
}

# Cache lesen
if [ "$use_cache" -eq 1 ] && [ "$refresh" -eq 0 ] && [ -s "$cache_file" ]; then
    cached="$(head -n1 "$cache_file")"
    if [ -n "$cached" ]; then
        printf '%s\n' "$cached"
        exit 0
    fi
fi

device="$(detect)"

# Letzter Ausweg: irgendwas Wahres ist besser als eine leere Zeile.
[ -z "$device" ] && device="$(uname -s) $(uname -m)"

if [ "$use_cache" -eq 1 ]; then
    # Schlaegt fehl bei read-only $HOME - dann eben jedes Mal neu ermitteln.
    mkdir -p "$(dirname "$cache_file")" 2>/dev/null \
        && printf '%s\n' "$device" > "$cache_file" 2>/dev/null
fi

printf '%s\n' "$device"
