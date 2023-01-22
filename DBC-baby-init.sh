#! /bin/bash

# runs initial safe commands to start a clean network 
# create a DBC from which the faucet is topped up 

#export OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4317" # Already the default
export RUST_LOG=sn_node=info # This filters the output for stdout/files, not OTLP
#export RUST_LOG_OTLP=sn_node=trace # This filters what is sent to OTLP endpoint 
export SAFE_ROOT=$HOME/.safe
export SAFE_BIN=/usr/local/bin
export TESTNET_NAME=baby-fleming
export WALLET_DATA=$SAFE_ROOT/testcreds.txt
echo ""
echo ""
echo "This script will remove all previous data from .safe/nodes/"
echo ""

echo "check trash-cli and jq packages are installed"
echo ""
echo ""
echo ""
echo ""
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

while :; do
  read -p "How many nodes (1 - 50)?: " NODES_QTY
  [[ $NODES_QTY =~ ^[0-9]+$ ]] || { echo "Enter a valid number"; continue; }
     if ((NODES_QTY >= 1 && NODES_QTY <= 50)); then
       echo "OK"
       break
     else
       echo "Number out of range, try again"
     fi
done


#clean up from any previous run
$SAFE_BIN/safe node killall > /dev/null
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
#safe wallet create
STASH=$($SAFE_BIN/safe wallet create  |echo $(grep -oP '(?<=Wallet created at:).*')|awk '{gsub(/^"|"$/, "", $0); print $0}') 
scho ""
echo ""
echo "The master wallet is at address: "$STASH
echo $STASH > $WALLET_DATA
echo "============================================"
$SAFE_BIN/safe wallet deposit --dbc ~/.safe/node/baby-fleming-nodes/sn-node-genesis/genesis_dbc $STASH
echo ""
$SAFE_BIN/safe wallet balance $STASH
