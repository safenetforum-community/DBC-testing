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

for i in {1..5}
do 
  touch account_$i.txt
  acct=$($SAFE_BIN/safe nrs register --json account_$i |jq '.[0]')
  pubk=$($SAFE_BIN/safe keys create  --json| jq '.[0]') 
  wurl=$( $SAFE_BIN/safe wallet create --json)
  echo $acct > account_$i.txt
  echo $pubk >> account_$i.txt
  echo $wurl >> account_$i.txt
  echo "----------------------------------------------------"
  echo ""
done

for files in $ACCTS/*
do
  nrs_acct=$( head -n 1 $files)
  pubk=$( tail -n 2 $files | head -n1)
  wurl=$( tail -n 1 $files)
  echo "----------------------------------------------------"
  echo $nrs_acct
  echo $pubk
  wurl=$(echo $wurl| sed 's/^\"\|\"$//g')
  echo $wurl

  #everyone should get a slice of pi
  $SAFE_BIN/safe wallet reissue --json --from $STASH 3.1415922 > ./dbc
  $SAFE_BIN/safe wallet deposit --json --dbc ./dbc $wurl 
  $SAFE_BIN/safe wallet balance $STASH
  $SAFE_BIN/safe wallet balance $wurl
  echo "----------------------------------------------------"
done  
