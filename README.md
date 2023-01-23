# DBC-testing

bash scripts to refine test procedures for community testnets

## DBC-baby-init.sh

The script will set up a baby-fleming local network, defaults to 20 nodes
create a keypair and wallet, then deposit the genesis DBC to the master wallet.  

## populate.sh

This  script creates accounts  consisting of keypairs and wallets and saves the output to a file.

the payout function loops through the files in the $ACCTS dir and sends some test SNT from the master wallet to each account.
