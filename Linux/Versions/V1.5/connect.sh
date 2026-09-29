#!/usr/bin/env bash

# --- CONFIGURATION ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/servers.json"
LOG_FOLDER="${SCRIPT_DIR}/logs"
LOG_FILE="${LOG_FOLDER}/manager.log"
VERSION="1.5.1"
DEV_TEAM="Rlverflow"
SOCIALS="github.com/Rlverflow"

# --- 1. INITIALIZATION ---
mkdir -p "$LOG_FOLDER"
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "[]" > "$CONFIG_FILE"
fi

# Color Definitions
CYAN='\033[0;36m'
GRAY='\033[0;90m'
WHITE='\033[1;37m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

# --- 2. CORE FUNCTIONS ---
write_log() {
    local message="$1"
    local timestamp
    timestamp="$(date +"%Y-%m-%d %H:%M:%S")"
    echo "[$timestamp] $message" >> "$LOG_FILE"
}

load_servers() {
    if [[ ! -s "$CONFIG_FILE" ]]; then
        echo "[]"
        return
    fi
    if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
        write_log "CRITICAL: Config corruption detected."
        echo "[]"
    else
        cat "$CONFIG_FILE"
    fi
}

save_servers() {
    local json_data="$1"
    echo "$json_data" | jq '.' > "$CONFIG_FILE"
}

generate_guid() {
    if command -v uuidgen &>/dev/null; then
        uuidgen
    elif [[ -f /proc/sys/kernel/random/uuid ]]; then
        cat /proc/sys/kernel/random/uuid
    else
        # Fallback pseudo-GUID using random numbers
        printf '%04x%04x-%04x-%04x-%04x-%04x%04x%04x\n' \
            $RANDOM $RANDOM $RANDOM $RANDOM $RANDOM $RANDOM $RANDOM $RANDOM
    fi
}

# --- 3. MAIN LOOP ---
while true; do
    clear
    servers_json=$(load_servers)
    count=$(echo "$servers_json" | jq 'length')

    echo -e "${CYAN}================================${RESET}"
    echo -e "${CYAN}   SSH MANAGER V${VERSION}${RESET}"
    echo -e "${GRAY}   By ${DEV_TEAM}${RESET}"
    echo -e "${CYAN}================================${RESET}"

    if [[ "$count" -eq 0 ]]; then
        echo -e "${YELLOW} [!] No servers found. Press [a] to add.${RESET}"
    else
        for (( i=0; i<count; i++ )); do
            display_index=$(( i + 1 ))
            name=$(echo "$servers_json" | jq -r ".[$i].name")
            ip=$(echo "$servers_json" | jq -r ".[$i].ip")
            ostype=$(echo "$servers_json" | jq -r ".[$i].ostype")

            if [[ "$ostype" == "Windows" ]]; then
                os_icon="[W]"
            else
                os_icon="[L]"
            fi

            echo -ne "${WHITE}(${display_index}) ${RESET}"
            echo -e "${GREEN}${os_icon} ${name} (${ip})${RESET}"
        done
    fi

    echo "--------------------------------"
    echo "[a] Add   [r] Remove   [l] Logs   [v] Info   [q] Quit"
    echo ""
    
    read -rp "Select Number or Option: " raw_input
    [[ -z "$raw_input" ]] && continue
    choice=$(echo "$raw_input" | tr '[:upper:]' '[:lower:]' | xargs)

    # --- 4. LOGIC: NUMERIC CONNECTION ---
    if [[ "$choice" =~ ^[0-9]+$ ]]; then
        idx=$(( choice - 1 ))
        if (( idx >= 0 && idx < count )); then
            t_name=$(echo "$servers_json" | jq -r ".[$idx].name")
            t_ip=$(echo "$servers_json" | jq -r ".[$idx].ip")
            t_user=$(echo "$servers_json" | jq -r ".[$idx].user")
            t_ostype=$(echo "$servers_json" | jq -r ".[$idx].ostype")

            write_log "CONNECT START: ${t_name} (${t_ip})"
            
            echo -e "\n${CYAN}>>> Connecting to ${t_name}...${RESET}"
            echo -e "${GRAY}>>> Port: 22 | OS: ${t_ostype}${RESET}"
            
            ssh_target="${t_user}@${t_ip}"
            ssh -o ConnectTimeout=10 "$ssh_target"
            exit_code=$?

            if [[ $exit_code -ne 0 ]]; then
                echo -e "\n${YELLOW}[!] SSH returned error code ${exit_code}${RESET}"
                write_log "CONNECT FAIL: ${t_name} (Code: ${exit_code})"
            else
                write_log "CONNECT END: ${t_name} session closed."
            fi
            read -rp $'\nPress Enter to return to menu'
        else
            echo -e "${RED}Invalid number: ${choice}${RESET}"
            sleep 1
        fi
        continue
    fi

    # --- 5. LOGIC: COMMAND SWITCH ---
    case "$choice" in
        'q')
            exit 0
            ;;
        'v')
            clear
            echo -e "${CYAN}================================${RESET}"
            echo -e "${CYAN}   ABOUT RLVERFLOW MANAGER      ${RESET}"
            echo -e "${CYAN}================================${RESET}"
            echo -e "${MAGENTA}Version: ${VERSION}\nTeam: ${DEV_TEAM}\nSocials: ${SOCIALS}${RESET}"
            read -rp $'\nEnter to return'
            ;;
        'l')
            clear
            echo -e "${YELLOW}--- RECENT ACTIVITY ---${RESET}"
            if [[ -f "$LOG_FILE" ]]; then
                tail -n 20 "$LOG_FILE"
            else
                echo "No logs found."
            fi
            read -rp $'\nEnter to return'
            ;;
        'a')
            clear
            echo -e "${CYAN}--- ADD NEW SERVER ---${RESET}"
            echo "Step 1: Select OS Type"
            echo "[1] Linux (Default)"
            echo "[2] Windows"
            read -rp "Choice: " os_in

            if [[ "$os_in" == "2" ]]; then
                ost="Windows"
            else
                ost="Linux"
            fi

            echo -e "\nStep 2: Server Credentials"
            read -rp "Nickname: " name
            read -rp "IP Address: " ip
            read -rp "Username: " user

            name=$(echo "$name" | xargs)
            ip=$(echo "$ip" | xargs)
            user=$(user_trimmed=$(echo "$user" | xargs); echo "$user_trimmed")

            if [[ -n "$name" && -n "$ip" ]]; then
                new_id=$(generate_guid)
                new_obj=$(jq -n \
                    --arg name "$name" \
                    --arg ip "$ip" \
                    --arg user "$user" \
                    --arg ostype "$ost" \
                    --arg id "$new_id" \
                    '{name: $name, ip: $ip, user: $user, ostype: $ostype, id: $id}')
                
                updated_list=$(echo "$servers_json" | jq --argjson newObj "$new_obj" '. + [$newObj]')
                save_servers "$updated_list"
                
                write_log "ADDED: ${name} (${ip})"
                echo -e "${GREEN}Saved successfully!${RESET}"
                sleep 1
            else
                echo -e "${RED}Aborted: Name and IP are required.${RESET}"
                sleep 2
            fi
            ;;
        'r')
            read -rp "Enter Number to remove: " num
            if [[ "$num" =~ ^[0-9]+$ ]]; then
                idx=$(( num - 1 ))
                if (( idx >= 0 && idx < count )); then
                    target_id=$(echo "$servers_json" | jq -r ".[$idx].id")
                    target_name=$(echo "$servers_json" | jq -r ".[$idx].name")
                    
                    updated_list=$(echo "$servers_json" | jq --arg id "$target_id" 'map(select(.id != $id))')
                    save_servers "$updated_list"
                    
                    write_log "REMOVED: ${target_name}"
                    echo -e "${YELLOW}Removed ${target_name}.${RESET}"
                    sleep 1
                fi
            fi
            ;;
        *)
            if [[ -n "$choice" ]]; then
                echo -e "${RED}Error: '${choice}' is not a valid command.${RESET}"
                sleep 1
            fi
            ;;
    esac
done