#!/bin/bash
# ===============================================
# ███████╗██╗   ██╗██╗██╗      █████╗ 
# ██╔════╝██║   ██║██║██║     ██╔══██╗
# █████╗  ██║   ██║██║██║     ███████║
# ██╔══╝  ╚██╗ ██╔╝██║██║     ██╔══██║
# ███████╗ ╚████╔╝ ██║███████╗██║  ██║
# ╚══════╝  ╚═══╝  ╚═╝╚══════╝╚═╝  ╚═╝
# 
# ▄▄▄▄▀ ▄  █ ████▄ █▄▄▄▄ 
# ▀▀▀ █    █   █ █   █ █  ▄▀ 
#     █    ██▀▀█ █   █ █▀▀▌  
#    █     █   █ ▀████ █  █  
#   ▀         █         █   
#            ▀         ▀    
# 
# EVIL ProxyChains Elite Manager v1.0
# ===============================================

# Display evil banner
clear
echo -e "\e[31m"  # Red color
cat << "EOF"

    ███████╗██╗   ██╗██╗██╗      █████╗ 
    ██╔════╝██║   ██║██║██║     ██╔══██╗
    █████╗  ██║   ██║██║██║     ███████║
    ██╔══╝  ╚██╗ ██╔╝██║██║     ██╔══██║
    ███████╗ ╚████╔╝ ██║███████╗██║  ██║
    ╚══════╝  ╚═══╝  ╚═╝╚══════╝╚═╝  ╚═╝

    ▄▄▄▄▀ ▄  █ ████▄ █▄▄▄▄ 
   ▀▀▀ █    █   █ █   █ █  ▄▀ 
       █    ██▀▀█ █   █ █▀▀▌  
      █     █   █ ▀████ █  █  
     ▀         █         █   
              ▀         ▀    
EOF
echo -e "\e[0m"  # Reset color

# Configuration
CONFIG="/etc/proxychains4.conf"
LOG="/var/log/evil_proxychains.log"
TEMP="/tmp/evil_proxychains.tmp"
MAX_PROXIES=50
TIMEOUT=5

# Verified Proxy Sources
SOURCES=(
    "https://raw.githubusercontent.com/TheSpeedX/PROXY-List/master/socks5.txt"
    "https://api.proxyscrape.com/v3/?request=getproxies&protocol=socks5&timeout=5000"
    "https://www.proxy-list.download/api/v1/get?type=socks5"
)

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"
}

# Proxy testing function
test_proxy() {
    local ip_port=$1
    if timeout $TIMEOUT curl -s -x "socks5://$ip_port" ifconfig.me >/dev/null; then
        log "☠️ Working proxy: $ip_port"
        return 0
    else
        log "⚰️ Dead proxy: $ip_port"
        return 1
    fi
}

# Main function
main() {
    # Prepare temp config
    echo "dynamic_chain" > "$TEMP"
    echo "proxy_dns" >> "$TEMP"
    echo "" >> "$TEMP"
    
    # Get proxies
    local working_proxies=()
    for src in "${SOURCES[@]}"; do
        log "Checking source: $src"
        proxies=$(timeout 10 curl -s "$src" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:[0-9]+')
        
        while read -r proxy; do
            if test_proxy "$proxy"; then
                working_proxies+=("$proxy")
                echo "socks5 $proxy" >> "$TEMP"
                [ ${#working_proxies[@]} -ge $MAX_PROXIES ] && break
            fi
        done <<< "$proxies"
        
        [ ${#working_proxies[@]} -ge $MAX_PROXIES ] && break
    done
    
    # Finalize
    if [ ${#working_proxies[@]} -gt 0 ]; then
        cp "$CONFIG" "${CONFIG}.bak"
        mv "$TEMP" "$CONFIG"
        log "👹 Success! Activated ${#working_proxies[@]} evil proxies!"
    else
        log "💀 Failed! No working proxies found."
    fi
}

# Run main function
main
