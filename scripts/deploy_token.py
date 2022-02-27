from brownie import accounts, config, GTMtoken, Game
from web3 import Web3

initial_supply = 2000000000000000000000
token_name = "GAMETMONEY"
token_symbol= "GTM"
KEPT_BALANCE = Web3.toWei(100, "ether")

def deploy_token():
    
    account = accounts[0]
    player = accounts[1]
    gtm_token = GTMtoken.deploy(
        initial_supply, {"from": account}
    )
    game = Game.deploy(
        player,
        {"from":player, 'value': '0.1 ether'}
    )


    tx =  gtm_token.transfer(game.address, gtm_token.totalSupply() - KEPT_BALANCE, {"from": account})

    tx.wait(1)

    return account, player, gtm_token, game
def main():
    deploy_token()
    