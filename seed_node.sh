#!/bin/bash

VALIDATOR="validator2"
CHAINID="cmcx_2121-1"
MONIKER="second"
MAINNODE_RPC="https://rpc2.catenarpc.com"
MAINNODE_ID="fd930ec05a4120c9f80086351354127545f659f7@8.209.96.231:26656"
KEYRING="os"
CONFIG="$HOME/.catenad/config/config.toml"
APPCONFIG="$HOME/.catenad/config/app.toml"

# install chain binary file
make install

# Set moniker and chain-id for chain (Moniker can be anything, chain-id must be same mainnode)
catenad init $MONIKER --chain-id=$CHAINID

# Fetch genesis.json from genesis node
curl $MAINNODE_RPC/genesis? | jq ".result.genesis" > ~/.catenad/config/genesis.json

catenad validate-genesis

# set seed to main node's id manually
# sed -i 's/seeds = ""/seeds = "'$MAINNODE_ID'"/g' ~/.catenad/config/config.toml

# add for rpc
sed -i 's/timeout_commit = "5s"/timeout_commit = "2s"/g' "$CONFIG"
sed -i 's/cors_allowed_origins = \[\]/cors_allowed_origins = \["*"\]/g' "$CONFIG"
sed -i 's/laddr = "tcp:\/\/127.0.0.1:26657"/laddr = "tcp:\/\/0.0.0.0:26657"/g' "$CONFIG"
sed -i '/\[api\]/,+3 s/enable = false/enable = true/' "$APPCONFIG"
sed -i '/\[api\]/,+3 s/swagger = false/swagger = true/' "$APPCONFIG"
sed -i 's/enabled-unsafe-cors = false/enabled-unsafe-cors = true/g'  "$APPCONFIG"
sed -i 's/api = "eth,net,web3"/api = "eth,txpool,personal,net,debug,web3"/g' "$APPCONFIG"

# add account for validator in the node
catenad keys add $VALIDATOR --keyring-backend $KEYRING

# run node
#catenad start --rpc.laddr tcp://0.0.0.0:26657 --pruning=nothing