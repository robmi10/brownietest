pragma solidity ^0.8.1;
import "./GTMtoken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Game{
    address public player;

    mapping(address => uint256) public Staking_amount;
    mapping(address => bool) public isStaking;
    mapping(address => uint256) public staking_time;
    mapping(address => bool) public is_token_alloed;

    mapping(address => uint256) public score_mapping;
    mapping(address => uint256) public pay_out_amount;
    //mapping(uint256 => address) public allowed_tokens;

    enum GAME_STATUS{GAME_START, GAME_ON, GAME_PENDING, GAME_ENDED}
    address public contract_address;
    uint256 public amount;
    uint256 public current_point;
    uint public playing_fee;
    GAME_STATUS game_status;
    uint256 public score_divider;
    uint256 public rate;
    uint256 public _timestamp;

    uint256 public reward_rate;
    
    event Payout(address, string);
    event Play(address _user, string);
    event Ended(address _from, uint256 _amount, GAME_STATUS, uint256 _reward);
    event New_payout(address _from, uint256 _amount, GAME_STATUS, uint256 _score, address _gmttoken);
    event Constructor_event(address, uint256, GAME_STATUS);
    event Curr_payout(address _from, uint256 _amount, GAME_STATUS);

    event Rate(uint256 _rate, uint256 _time,  uint256 _input, uint256 _staking_amount);

    event Staking(address _staker, bool _on, string _message, uint256 _value);
    event Un_Staking(address _staker, uint256 _amount, bool _on, string _message);

    event Stake_status(address _staker, uint256 _rate, bool _stake_status, uint256 _amount ,string _message, uint256 _time_stamp);

    address [] public allowed_tokens;
    IERC20 public GTMToken;
    constructor(address _GTMTokenAddress) payable {
        game_status = GAME_STATUS.GAME_ON;
        player = msg.sender;
        playing_fee = 100000000000000000;
        score_divider = 100;
        GTMToken = IERC20(_GTMTokenAddress);
        contract_address = address(this);
        rate = 1;
        emit Constructor_event(player, score_divider, game_status);
    }
    struct Player
    {
        address player;
        uint256 score;
    }
    Player _player;
    //En funktion som startar spelet och känner igen poängen
    //En funktion som betalar ut ens egna token varje gång spelaren når poängen
    //En funktion som låter spelaren stakea bnb 

    /* function is_token_allowed() public{
        uint256 _tokenindex = 0;
        for(uint256 _tokenindex = 0; _tokenindex > _tokenindex.length; _tokenindex++){
            if(allowed_tokens[_tokenindex]){
                return true;
            }
        }
        return false;
    } */

    function addallowed_tokens(address _token_address) public{
        allowed_tokens.push(_token_address);
    }

    function get_staker_time () public payable returns(uint256){
        return staking_time[msg.sender];
    }
    
    function get_stake_status () public payable returns(bool, uint256, uint256, uint256){
        bool curr_stake_status = isStaking[msg.sender];
        uint256 amount_staked = Staking_amount[msg.sender];
        uint256 get_time_stamp = staking_time[msg.sender];

        emit Stake_status(msg.sender, reward_rate, curr_stake_status, amount_staked ,"stake status", get_time_stamp);

        return (curr_stake_status, reward_rate, amount_staked, get_time_stamp);
    }

    function stake(address _token_address, uint256 _amount) public payable{
        require(isStaking[msg.sender] == false, 'Already staking!');
        //require(is_token_allowed(_token_address), 'Token is not allowed for staking!');
        require(Staking_amount[msg.sender] == 0, "Staking amount is not 0!");

        IERC20(_token_address).transferFrom(msg.sender, address(this) , _amount);
        isStaking[msg.sender] = true;
        Staking_amount[msg.sender] += _amount;

        staking_time[msg.sender] = block.timestamp;
        emit Staking(msg.sender, true, "staking now!", msg.value);
    }

    function unstake(address _token_address) public payable{    
        require(isStaking[msg.sender], 'Not staking!');
        uint256 _staking_balance = Staking_amount[msg.sender];

        IERC20(_token_address).transfer(msg.sender , _staking_balance);
        isStaking[msg.sender] = false;
        staking_time[msg.sender] = 0;
        Staking_amount[msg.sender] = 0;
        emit Un_Staking(msg.sender, _staking_balance, isStaking[msg.sender], "Ended staking!");
    }
    
    
    //1645005098 24 days 
    //1646013963 13 days
    //1647113963 2 hours
    //1647005098 1 day
    //1647116098 minutes

    function staking_rewards() public payable returns(uint256){
        require(isStaking[msg.sender] == true, 'Not staking!');
        uint256 _staker_time = staking_time[msg.sender];
        uint256 _staking_amount = Staking_amount[msg.sender];
        uint256 time_amount = block.timestamp - _staker_time;
        uint256 reward_payout = time_amount * _staking_amount * rate/100000;
        
        reward_rate = reward_payout;

        emit Rate(time_amount, _staker_time, reward_payout, _staking_amount);
        return reward_payout;
    }
    
    function play () public payable{
        require(msg.value == 10000000000000000, "you must pay to play");
        game_status = GAME_STATUS.GAME_START;
        emit Play(msg.sender, "Game is on!"); 
    }

    function get_pay_amount(uint256 new_score) public returns(uint256){
        uint256 current_payout = new_score / score_divider;
        emit Curr_payout(msg.sender, current_payout, game_status);
        return current_payout;
    } 

    function payout_amount(uint256 _score, address _gmttoken, address _token_address) public {
        require(game_status ==  GAME_STATUS.GAME_START);
        uint256 final_pay_out = _score / score_divider;
        pay_out_amount[msg.sender] += final_pay_out;
        emit New_payout(msg.sender, final_pay_out, game_status, _score, _gmttoken);
        end_game(_token_address);
    }

    function end_game(address _token_address) public{
        game_status = GAME_STATUS.GAME_ENDED;
        uint256 pay_out = pay_out_amount[msg.sender];
        uint256 rate_reward = 0;
        if(isStaking[msg.sender]){

            rate_reward= staking_rewards();
            GTMToken.transfer(msg.sender, pay_out * rate_reward);

            emit Ended(player, pay_out, game_status, rate_reward);
            
        }else{

            GTMToken.transfer(msg.sender, pay_out * 1e18);

            emit Ended(player, pay_out, game_status, rate_reward);

        }
        
        
    }

}