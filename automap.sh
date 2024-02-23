#!/bin/bash

BLUE="\033[1;34m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
ORANGE="\033[1;31m"
NC="\033[0m" # no Color

SCAN_OPTION="both"
OUTPUT_DIR="."
SHOW_HELP="false"

usage() {
    echo -e "${GREEN}Usage: $0 [options] <TARGET_IP_1> [TARGET_IP_2] ...${NC}"
    echo "Options:"
    echo "  -a  Scan all TCP ports."
    echo "  -u  Scan UDP ports."
    echo "  -d  Specify the directory where the .nmap files will be saved (default is the current directory)."
    echo "  -h  Show this help message."
    exit 1
}

while getopts "aud:h" option; do
    case $option in
        a) SCAN_OPTION="all";;
        u) SCAN_OPTION="udp";;
        d) OUTPUT_DIR=$OPTARG;;
        h) SHOW_HELP="true";;
        *) usage;;
    esac
done

if [ "$SHOW_HELP" = "true" ] || [ $OPTIND -eq 1 ]; then
    usage
fi

shift $((OPTIND-1))

# ensure at least one target is specified
if [ $# -eq 0 ]; then
    usage
fi

# validate and keep sudo session active
sudo -v
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
fi

colorize_output() {
    while IFS= read -r line; do
        if echo "$line" | grep -qE 'http|www|apache'; then
            echo -e "${BLUE}${line}${NC}"
        elif echo "$line" | grep -qE 'pop3|imap|smtp'; then
            echo -e "${GREEN}${line}${NC}"
        elif echo "$line" | grep -qE 'mysql|oracle|sql|database'; then
            echo -e "${YELLOW}${line}${NC}"
        elif echo "$line" | grep -qE 'ssh|rdp'; then
            echo -e "${ORANGE}${line}${NC}"
        else
            echo "$line"
        fi
    done
}

perform_scan() {
    for TARGET_IP in "$@"; do
        LAST_OCTET=$(echo "$TARGET_IP" | rev | cut -d '.' -f 1 | rev)

        if [ "$SCAN_OPTION" = "all" ] || [ "$SCAN_OPTION" = "both" ]; then
            OUTPUT_FILE="${OUTPUT_DIR}/${LAST_OCTET}_all_ports.nmap"
            echo "Starting Nmap scan for all TCP ports on $TARGET_IP..."
            sudo nmap -Pn -T4 -p- -oN "$OUTPUT_FILE" $TARGET_IP | colorize_output
            echo "Results saved to $OUTPUT_FILE"
        fi

        if [ "$SCAN_OPTION" = "udp" ] || [ "$SCAN_OPTION" = "both" ]; then
            OUTPUT_FILE="${OUTPUT_DIR}/${LAST_OCTET}_udp.nmap"
            echo "Starting Nmap scan for UDP ports on $TARGET_IP..."
            sudo nmap -sU -sC -oN "$OUTPUT_FILE" $TARGET_IP | colorize_output
            echo "Results saved to $OUTPUT_FILE"
        fi
    done
}

perform_scan "$@"

# Invalidate sudo session
sudo -k