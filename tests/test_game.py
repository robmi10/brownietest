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

    assert game_token_balance == 1999999900000000000000000000
    return account, player, gtm_token, game

def test_start_game():
    account, player, gtm_token, game = test_transfer_token() 
    player_balance = player.balance()
    game_on = game.play({"from": player, 'value': '0.01 ether'})

    
    print("game_on --->", game_on.events)
    print("player current balance ->", player_balance)
    assert 1 == 1
    return account, player, gtm_token, game, game_on
    
def test_staking():
    account, player, gtm_token, game, game_on = test_start_game()
    amount = 5 * 1000000000000000000
    print("current game address approve !", game.address)

    gtm_token.approve(game.address, amount, {"from": player})
    staking_on = game.stake(gtm_token.address, amount, {"from": player})

    #unstake = game.unstake(gtm_token.address, {"from": player})
    #unstake.wait(1) 
    assert 1 == 1
    return account, player, gtm_token, game, game_on, staking_on
    
    
def test_play_game():
    
    account, player, gtm_token, game, game_on, staking_on = test_staking()
    pre_player_token_balance = gtm_token.balanceOf(player.address)
    print("inside testgame 2")

    current_payout = game.get_pay_amount(2000)

    print("current balance -->", current_payout.return_value)

   

    #gtm_token.approve(game.address, current_payout.return_value, {"from": account})

    game_payout = game.payout_amount(600, player, gtm_token.address, {"from": player})

    post_gtm_token_balance = gtm_token.balanceOf(account.address)
    post_game_token_balance = gtm_token.balanceOf(game.address)
    post_player_token_balance = gtm_token.balanceOf(player.address)


    get_reward_rate = game.get_stake_status({"from": player})

    print("get_reward_rate status -->", get_reward_rate.return_value)

    print("get_reward_rate event -->", get_reward_rate.events)

    print("account! ->", player)
    print("Payout func ->", game_payout)
    print("Payout event ->", game_payout.events)
    print("pre_player_token_balance ->", pre_player_token_balance)
    print("Pre balance GTM ->", pre_player_token_balance)
    print("Post balance player ->", post_player_token_balance)
    print("Post balance contract ->", post_game_token_balance)
    print("Post gtm_token contract ->", post_gtm_token_balance)

    print("accounts rinkeby ->", accounts.load('rinkeby'))




    """ print("current pay out amount ->", current_payout)
    gtm_token.approve(game.address, current_payout, {'from': account})
    print("game_payout -->", game_payout)
    print("Pre balance GTM ->", pre_player_token_balance)
    print("Post balance GTM ->", post_player_token_balance) """

    assert 1 == 2
