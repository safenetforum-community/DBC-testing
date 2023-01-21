# DBC-testing

bash scripts to refine test procedures for community testnets

## DBC-baby-init.sh

Use latest release
Safe Network v0.15.0/v0.16.12/v0.77.6/v0.72.23/v0.75.3/v0.68.4
for now.
The script will set up a 20 node baby-fleming local network,
create a keypair and wallet, then deposit the genesis DBC to  
the master wallet.  
TODO: Make QTY_NODES configureable  


## populate.sh

This wee script creates keypairs and wallets and saves the output to a json file.
Well it will when it is working properly ...
Intended to use the safe nrs command to create a network address for each account 
and store the keys and wallet address at a human-readable location on the SAFE network 
