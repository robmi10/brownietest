from brownie import accounts, config, GTMtoken, Game, WETHtoken
from web3 import Web3
import yaml
import json
import os
import shutil

initial_supply = 2000000000000000000000000000
weth_token_supply = 800000000000000000000000000
token_name = "GAMETMONEY"
token_symbol= "GTM"
KEPT_BALANCE = Web3.toWei(100, "ether")

NEW_BALANCE = Web3.toWei(10, "ether")
NEW_ACC = "0xcCaf6855546eD82636b9A6093129BB4E47124bCc"

def main():
    account = accounts.add(config['wallets']["from_key"])

    weth_token = WETHtoken.deploy(
        weth_token_supply, {"from": account}
    )

    tx =  weth_token.transfer(NEW_ACC, NEW_BALANCE, {"from": account})
    tx.wait(1)