#!/usr/bin/env bash

# runs initial safe commands to start a clean network 
# create a master wallet to hold genesis DBC

set_env_vars () {
    #export OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4317" # Already the default
    export RUST_LOG=sn_node=info # This filters the output for stdout/files, not OTLP
    #export RUST_LOG_OTLP=sn_node=trace # This filters what is sent to OTLP endpoint 
    export SAFE_ROOT=$HOME/.safe
    export SAFE_BIN=/usr/local/bin
    export TESTNET_NAME=baby-fleming
    export WALLET_DATA=$SAFE_ROOT/testcreds.txt
    export ACCTS=$SAFE_ROOT/accounts/
}

intro () {
    echo ""
    echo ""
    echo "This script will remove all previous data from .safe/nodes/"   
    echo "and check for and install trash-cli and jq packages"
    echo ""
    echo ""
    echo ""
    echo ""
    echo ""
}

check_packages () {
    packages=("trash-cli" "jq" )
    not_installed=()
    for package in "${packages[@]}"; do
    if dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q "ok installed"; then
        echo "$package is already installed"
    else
        not_installed+=($package)
    fi
    done
    if [ ${#not_installed[@]} -ne 0 ]; then
    echo "Installing ${not_installed[*]}"
    sudo apt-get install -y ${not_installed[*]}
    else
    echo "All packages already installed"
    fi
}

get_nodes_qty () {
    while :; do
    read -p "How many nodes [20]?: " NODES_QTY
    NODES_QTY=${NODES_QTY:-20} 
    [[ $NODES_QTY =~ ^[0-9]+$ ]] || { echo "Enter a valid number"; continue; }
        if ((NODES_QTY >= 11 && NODES_QTY <= 50)); then
        echo "OK"
        break
        else
        echo "Choose between 11 and 50 nodes"
        fi
    done
}

clean_up () {
    #clean up from any previous run
    $SAFE_BIN/safe node killall > /dev/null
     [ -f "$WALLET_DATA " ] && rm -v $WALLET_DATA   #make sure this is cleared    
    echo ""
    echo ""
    sleep 1
    cd $SAFE_ROOT/node
    trash-put -r -v ./baby* ./local*
}

init_network () {
    echo "============================================"
    echo ""
    echo "Allow time for all "$NODES_QTY" nodes to be started"
    echo ""
    echo ""
    echo ""
    echo ""
    echo ""
    echo ""
    $SAFE_BIN/safe node run-baby-fleming --nodes $NODES_QTY
    echo ""
    echo "============================================================="
}

check_network () {
    $SAFE_BIN/safe networks switch $TESTNET_NAME
    $SAFE_BIN/safe networks
    $SAFE_BIN/safe networks check
    $SAFE_BIN/safe networks sections
    
}


init_stash () {
    $SAFE_BIN/safe keys create --for-cli #--json  
    STASH=$($SAFE_BIN/safe wallet create  |echo $(grep -oP '(?<=Wallet created at:).*')|awk '{gsub(/^"|"$/, "", $0); print $0}') 
    echo $STASH > $WALLET_DATA
    echo ""
    echo ""
    echo "The master wallet is at address: "$STASH
    $SAFE_BIN/safe wallet deposit --dbc ~/.safe/node/baby-fleming-nodes/sn-node-genesis/genesis_dbc $STASH
    echo "============================================"
    ls -l $WALLET_DATA
}

set_env_vars
intro
check_packages
get_nodes_qty
clean_up
init_network
check_network

sleep 2

init_stash

exit 0
