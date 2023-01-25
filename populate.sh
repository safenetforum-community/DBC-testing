#! /bin/bash

# creates "user accounts" for testing
# create a keypair and wallet for each "user" 


set_env_vars () {
    #export OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4317" # Already the default
    export RUST_LOG=sn_node=info, sn_cli=trace # This filters the output for stdout/files, not OTLP
    #export RUST_LOG_OTLP=sn_node=trace # This filters what is sent to OTLP endpoint 
    export SAFE_ROOT=$HOME/.safe
    export SAFE_BIN=/usr/local/bin
    export TESTNET_NAME=baby-fleming
    export WALLET_DATA=$SAFE_ROOT/testcreds.txt
    export ACCTS=/tmp/ACCTS
    #echo "done set_env_vars"
}


check_stash () {
  cd $SAFE_ROOT
  export STASH=$(cat $WALLET_DATA)
  echo "done check Stash at " $STASH
}

init_accts () {
  [ ! -d "$ACCTS" ] && mkdir $ACCTS  
  cd $ACCTS
  rm -v *.txt
}

get_accts_qty () {
    while :; do
    read -p "How many accounts [5]?: " ACCTS_QTY
    ACCTS_QTY=${ACCTS_QTY:-5} 
    [[ $ACCTS_QTY =~ ^[0-9]+$ ]] || { echo "Enter a valid number"; continue; }
        if ((ACCTS_QTY >= 1 && ACCTS_QTY <= 500)); then
        echo "OK"
        break
        else
        echo "Choose between 1 and 500 wallets"
        fi
    done
}

create_accts () {
  cd $ACCTS
  for i in {1..100}
  do 
    acct=$($SAFE_BIN/safe nrs register --json account_$i |jq '.[0]')
    pubk=$($SAFE_BIN/safe keys create  --json| jq '.[0]') 
    wurl=$( $SAFE_BIN/safe wallet create --json)
    echo "----- " account_$i " --------------------------------------"
    echo ""
    echo ""
    payout
  done
}

payout () {
  cd $ACCTS
   
  wurl=$(echo $wurl| sed 's/^\"\|\"$//g')
  echo " Payout to : "$wurl

    #everyone should get a slice of pi

    payout_dbc=$($SAFE_BIN/safe wallet reissue --json --from $STASH 3.1415922)
    $SAFE_BIN/safe wallet deposit --json --dbc $payout_dbc $wurl 
    echo "Master "$($SAFE_BIN/safe wallet balance $STASH)
    echo "----------------------------------------------------"
    $SAFE_BIN/safe wallet balance $wurl
    echo "----------------------------------------------------"

}

set_env_vars
check_stash
init_accts
get_accts_qty
create_accts
exit 0