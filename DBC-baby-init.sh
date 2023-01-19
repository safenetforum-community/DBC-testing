#! /bin/bash

# runs initial safe commands to start a clean network 
# create a DBC from which the faucet is topped up 

#sudo apt-get install trash-cli   # first run
#export OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4317" # Already the default
export RUST_LOG=sn_node=info # This filters the output for stdout/files, not OTLP
#export RUST_LOG_OTLP=sn_node=trace # This filters what is sent to OTLP endpoint 
export SAFE_ROOT=$HOME/.safe
export SAFE_BIN=/usr/local/bin
export TESTNET_NAME=baby-fleming
export NODES_QTY=20
#clean up from any previous run
$SAFE_BIN/safe node killall
cd $SAFE_ROOT/node
trash-put -r -v ./baby* ./local*
#$SAFE_BIN/safe config clear

echo "============================================"
echo ""
echo "Allow time for all "$NODES_QTY" nodes to be started"

$SAFE_BIN/safe node run-baby-fleming --nodes $NODES_QTY

echo ""
echo "============================================================="

$SAFE_BIN/safe networks switch $TESTNET_NAME
$SAFE_BIN/safe networks
$SAFE_BIN/safe networks check
$SAFE_BIN/safe networks sections
$SAFE_BIN/safe keys create --for-cli --json  
safe wallet create
#STASH=$($SAFE_BIN/safe wallet create |echo $(grep -oP '(?<=Wallet created at:).*')|awk '{gsub(/^"|"$/, "", $0); print $0}') 

echo "The faucet wallet is at address: "$STASH
echo "============================================"
$SAFE_BIN/safe wallet deposit --dbc ~/.safe/node/baby-fleming-nodes/sn-node-genesis/genesis_dbc $STASH
$SAFE_BIN/safe wallet balance $STASH
