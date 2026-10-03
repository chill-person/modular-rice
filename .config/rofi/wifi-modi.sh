#!/usr/bin/env bash

ICON_DIR="$HOME/.config/rofi/icons"
WIFI_ICON="$ICON_DIR/wifi.svg"
WIFI_OFF_ICON="$ICON_DIR/wifi-off.svg"

mkdir -p "$ICON_DIR"

# Small white Wi-Fi icon
cat > "$WIFI_ICON" <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 32 32">
<path fill="#ffffff" d="M16 25.5a1.8 1.8 0 1 0 0-3.6a1.8 1.8 0 0 0 0 3.6ZM11.2 19.2a6.8 6.8 0 0 1 9.6 0l1.5-1.5a8.9 8.9 0 0 0-12.6 0l1.5 1.5ZM8 15.5a11.3 11.3 0 0 1 16 0l1.5-1.5a13.4 13.4 0 0 0-19 0L8 15.5Z"/>
</svg>
EOF

# Small white Wi-Fi-off icon
cat > "$WIFI_OFF_ICON" <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 32 32">
<path fill="#ffffff" d="M16 25.5a1.8 1.8 0 1 0 0-3.6a1.8 1.8 0 0 0 0 3.6ZM11.2 19.2a6.8 6.8 0 0 1 9.6 0l1.5-1.5a8.9 8.9 0 0 0-12.6 0l1.5 1.5ZM8 15.5a11.3 11.3 0 0 1 16 0l1.5-1.5a13.4 13.4 0 0 0-19 0L8 15.5Z"/>
<path fill="#ffffff" d="M7 7L25 25L23.5 26.5L5.5 8.5Z"/>
</svg>
EOF


# ============================================================
# DISPLAY MODE
# ============================================================

if [ -z "$1" ]; then

    STATUS=$(nmcli radio wifi)

    # Wi-Fi toggle
    if [ "$STATUS" = "enabled" ]; then
        printf 'Turn Wi-Fi Off\0icon\x1f%s\n' "$WIFI_OFF_ICON"
    else
        printf 'Turn Wi-Fi On\0icon\x1f%s\n' "$WIFI_ICON"
    fi

    # Get SSIDs, remove duplicates, then add icons.
    #
    # Important:
    # We DO NOT pipe the icon-bearing output through sort/awk.
    # Rofi gets clean NUL-separated entries.
    nmcli -t -f SSID device wifi list |
    while IFS= read -r ssid; do
        [ -z "$ssid" ] && continue
        [ "$ssid" = "--" ] && continue

        printf '%s\n' "$ssid"
    done |
    awk '!seen[$0]++' |
    while IFS= read -r ssid; do
        printf '%s\0icon\x1f%s\n' "$ssid" "$WIFI_ICON"
    done


# ============================================================
# SELECTION MODE
# ============================================================

else

    CHOICE="$1"

    # Toggle Wi-Fi
    if [ "$CHOICE" = "Turn Wi-Fi Off" ]; then
        nmcli radio wifi off
        exit 0
    fi

    if [ "$CHOICE" = "Turn Wi-Fi On" ]; then
        nmcli radio wifi on
        exit 0
    fi


    # Selected network
    SSID="$CHOICE"

    # Find security for this exact SSID
    SECURITY=$(
        nmcli -t -f SSID,SECURITY device wifi list |
        while IFS=: read -r found_ssid security; do
            if [ "$found_ssid" = "$SSID" ]; then
                printf '%s\n' "$security"
                break
            fi
        done
    )

    # Password required
    if [ -n "$SECURITY" ] && [ "$SECURITY" != "--" ]; then

        PASS=$(rofi -dmenu -p "Password for $SSID")

        [ -z "$PASS" ] && exit 0

        nmcli device wifi connect "$SSID" password "$PASS"

    # Open network
    else

        nmcli device wifi connect "$SSID"

    fi

fi