import pytest
from brownie import accounts, config, GTMtoken, Game
from scripts.deploy_token import deploy_token
initial_supply = 2000000000000000000000
token_name = "GAMETMONEY"
token_symbol= "GTM"


def test_transfer_token():    
    print("transfer token")
    account, player, gtm_token, game = deploy_token()
    gtm_token_balance = gtm_token.balanceOf(account.address)
    game_token_balance = gtm_token.balanceOf(game.address)
    print("current first_balance ->", gtm_token_balance)
    print("current game token ->", game_token_balance)

    assert game_token_balance == 1900000000000000000000
    return account, player, gtm_token, game

def test_start_game():
    account, player, gtm_token, game = test_transfer_token() 
    player_balance = player.balance()
    game_on = game.play({"from": player, 'value': '0.1 ether'})

    
    print("game_on --->", game_on.events)
    print("player current balance ->", player_balance)
    assert 1 == 1
    return account, player, gtm_token, game, game_on
    
def test_play_game():
    
    account, player, gtm_token, game, game_on = test_start_game()
    pre_player_token_balance = gtm_token.balanceOf(game.address)
    print("inside testgame 2")
    game_payout = game.payout_amount(2000, gtm_token.address, {"from": player})
    post_player_token_balance = gtm_token.balanceOf(player.address)

    print("account! ->", player)
    print("Payout func ->", game_payout)
    print("Payout event ->", game_payout.events)

    """ print("current pay out amount ->", current_payout)
    gtm_token.approve(game.address, current_payout, {'from': account})
    print("game_payout -->", game_payout)
    print("Pre balance GTM ->", pre_player_token_balance)
    print("Post balance GTM ->", post_player_token_balance) """

    assert 1 == 2
