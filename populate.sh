#! /bin/bash

# creates "user accounts" for testing
# create a keypair and wallet for each "user" 


#export OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4317" # Already the default
export RUST_LOG=sn_node=info # This filters the output for stdout/files, not OTLP
#export RUST_LOG_OTLP=sn_node=trace # This filters what is sent to OTLP endpoint     
export SAFE_ROOT=$HOME/.safe
export SAFE_BIN=\usr\local\bin
export ACCTS=$SAFE_ROOT/accounts
export RUNDATA=$SAFE_ROOT/testcreds
cd $SAFE_ROOT

[ ! -d "$ACCTS" ] && mkdir $ACCTS  

cd $ACCTS

([[ -f "accounts.json" ]] && rm --recursive --verbose "accounts.json" || exit 0)
touch accounts.json
echo '{ "object" : "List of accounts", [' >> accounts.json


for i in {1..10}
do
  tmp=$(safe nrs register --json account_$i |jq '.[0]')
  echo '{"account_'$i'" :'$tmp ',' >> accounts.json
  echo '"publicKey" : '$($SAFE_BIN/safe keys create  --json| jq '.[0]')',' >> accounts.json
  echo '"walletUrl" : '$( $SAFE_BIN/safe wallet create --json)'},' >> accounts.json
  
done

echo   "]}" >> accounts.json

$SAFE_BIN/safe files put $ACCTS/accounts.json

cat accounts.json
cat accounts.json |jq