#!/bin/sh

INDEX=1
ACTION=list

devices=$(lsblk -Jplno NAME,TYPE,RM,SIZE,MOUNTPOINT,VENDOR)

main() {
    if [[ $1 =~ ^[0-9]+$ ]]; then
        INDEX=$1
    else
        echo "Not a number"
        return
    fi

    case "$2" in
        --toggle)
            deviceIndex=1
            for device in $(echo "$devices" | jq -r '.blockdevices[]  | select(.type == "part") | select(.rm == true) | .name'); do
                if [[ $deviceIndex == $1 ]]; then
                    mountpoint=$(echo "$devices" | jq -r '.blockdevices[]  | select(.name == "'"$device"'") | .mountpoint' | tr -d ' ')
                    if [ $mountpoint = "null" ]; then
                        udisksctl mount --no-user-interaction -b "$device"
                    else
                        udisksctl unmount --no-user-interaction -b "$device"
                    fi
                fi
                deviceIndex=$((deviceIndex + 1))
            done
            ;;
        *)
            output=""
            deviceIndex=1

            for device in $(echo "$devices" | jq -r '.blockdevices[]  | select(.type == "part") | select(.rm == true) | .name'); do
                if [[ $deviceIndex == $1 ]]; then
                    #
                    unmounted=$(echo "$device" | tr -d "[:digit:]")
                    vendor=$(echo "$devices" | jq -r '.blockdevices[]  | select(.name == "'"$unmounted"'") | .vendor' | tr -d ' ')
                    size=$(echo "$devices" | jq -r '.blockdevices[]  | select(.name == "'"$device"'") | .size' | tr -d ' ')
                    mountpoint=$(echo "$devices" | jq -r '.blockdevices[]  | select(.name == "'"$device"'") | .mountpoint' | tr -d ' ')
                    if [ $mountpoint = "null" ]; then
                        mountpoint=""
                    else
                        mountpoint=" %{F#7aa2f7}Mounted%{F-}"
                    fi
                    output="$vendor $size$mountpoint"
                fi
                deviceIndex=$((deviceIndex + 1))
            done
            echo "$output"
            ;;
    esac
}

main "$@"
