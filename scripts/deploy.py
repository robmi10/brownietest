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

NEW_BALANCE = Web3.toWei(500, "ether")

PLAYER_BALANCE = Web3.toWei(20, "ether")

NEW_ACC = "0xcCaf6855546eD82636b9A6093129BB4E47124bCc"

def deploy_token(front_end_update=False):
    
    account = accounts.add(config['wallets']["from_key"])
    #account = accounts[0]
    #player = accounts[1]

    gtm_token = GTMtoken.deploy(
        initial_supply, {"from": account}
    )
    game = Game.deploy(
        gtm_token.address,
        {"from":account, 'value': '0.001 ether'}
    )

    weth_token = WETHtoken.deploy(
        weth_token_supply, {"from": account}
    )

    tx =  weth_token.transfer(NEW_ACC, NEW_BALANCE, {"from": account})
    tx.wait(1)

    #tx2 =  gtm_token.transfer(player, PLAYER_BALANCE, {"from": account})
    #tx2.wait(1)

    tx3 =  gtm_token.transfer(game.address, gtm_token.totalSupply() - KEPT_BALANCE, {"from": account})
    tx3.wait(1)

    return account, gtm_token, game

""" def add_token():
    allowed_tokens = [bnb_token]
 """

def update_front_end():
    copy_folder_to_frontend("./build", "../GameDapp/game-dapp/chain-info")

    with open("brownie-config.yaml", "r") as brownie_config:
        config_dict = yaml.load(brownie_config, Loader=yaml.FullLoader)
        with open("../GameDapp/game-dapp/src/brownie-config.json", "w") as brownie_config_json:
            json.dump(config_dict, brownie_config_json)
        print("Front end updated")

def copy_folder_to_frontend(src, dest):
    if os.path.exists(dest):
        shutil.rmtree(dest)
    shutil.copytree(src, dest)
    

def main():
    deploy_token(front_end_update=True)
    update_front_end()
    