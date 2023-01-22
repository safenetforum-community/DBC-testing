#! /bin/bash

# creates "user accounts" for testing
# create a keypair and wallet for each "user" 


#export OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4317" # Already the default
export RUST_LOG=sn_node=info # This filters the output for stdout/files, not OTLP
#export RUST_LOG_OTLP=sn_node=trace # This filters what is sent to OTLP endpoint     
export SAFE_ROOT=$HOME/.safe
export SAFE_BIN=/usr/local/bin
export ACCTS=$SAFE_ROOT/accounts/
export WALLET_DATA=$SAFE_ROOT/testcreds.txt
cd $SAFE_ROOT
STASH=$(cat $WALLET_DATA)
echo $STASH
[ ! -d "$ACCTS" ] && mkdir $ACCTS  

cd $ACCTS
rm -v *.txt 
#([[ -f "*.txt" ]] && rm --recursive --verbose "*.txt" || exit 0)
#touch accounts.json
#echo '{ "object" : "List of accounts", [' >> accounts.json


for i in {1490..1495}
do
  #echo "---------------------------------------------------"
  touch account_$i.txt
  acct=$(safe nrs register --json account_$i |jq '.[0]')
  echo $acct > account_$i.txt
  #echo '{"account_'$i'" :'$acct ',' >> accounts.json

  pubk=$($SAFE_BIN/safe keys create  --json| jq '.[0]') 
  echo $pubk >> account_$i.txt
  #echo '"publicKey" : '$pubk',' >> accounts.json

  wurl=$( $SAFE_BIN/safe wallet create --json)
  echo $wurl >> account_$i.txt
 # echo '"walletUrl" : ' $wurl '},' >> accounts.json
  echo "----------------------------------------------------"
  echo ""
done

#echo   "]}" >> accounts.json

#$SAFE_BIN/safe files put $ACCTS/accounts.json

ls -al .


for files in $ACCTS/*
  do
  nrs_acct=$( head -n1 $files)
  echo $nrs_acct
  pubk=$(tail -n2 $files| head -n1)
  echo $pubk
  wurl=$( tail -n1 $files)
  echo $wurl

  safe wallet reissue --json --from $STASH 42 > dbc
  safe wallet deposit --json --dbc ./dbc $wurl 


done  
