pragma solidity ^0.8.1;
import "./GTMtoken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Game{
    address public player;

    mapping(address => uint256) public StakingAmount;
    mapping(address => bool) public isStaking;
    mapping(address => uint256) public stakingTime;
    mapping(address => uint256) public payOutAmount;

    enum GAME_STATUS{GAME_START, GAME_ON, GAME_PENDING, GAME_ENDED}

    GAME_STATUS game_status;
    uint256 public scoreDivider;
    uint256 public rate;
    
    event PlayEvent(address indexed _user, bool indexed _status);
    event EndedEvent(address indexed _from, uint256 indexed _amount, uint256  indexed _reward, GAME_STATUS);
    event PayoutEvent(address indexed _from, uint256 indexed _amount, uint256 indexed _score, GAME_STATUS);
    event RateEvent(uint256 indexed _rate, uint256 indexed _time,  uint256 indexed _input, uint256 indexed _stakingAmount);
    event StakingEvent(address indexed _staker, bool indexed _on, string indexed _message, uint256 indexed _value);
    event UnstakeEvent(address  _staker, uint256 indexed _amount, bool indexed _on, string indexed _message);
    event StakeStatusEvent(address _staker, bool _stake_status, uint256 _amount ,string _message, uint256 _time_stamp);

    IERC20 public GTMToken;
    constructor(address _GTMTokenAddress) payable {
        gameStatus = GAME_STATUS.GAME_ON;
        player = msg.sender;
        scoreDivider = 100;
        GTMToken = IERC20(_GTMTokenAddress);
        rate = 1;
    }
      
    function getStakeStatus () public payable returns(bool, uint256, uint256, uint256){
        bool stakeStatus = isStaking[msg.sender];
        uint32 amountStaked = StakingAmount[msg.sender];
        uint32 timeStamp = stakingTime[msg.sender];
        emit StakeStatusEvent(msg.sender, stakeStatus, amountStaked ,"stake status", timeStamp);
        return (stakeStatus, amountStaked, timeStamp);
    }

    function stake() public payable{
        require(!isStaking[msg.sender], 'Already staking!');
        require(StakingAmount[msg.value] > 0, "Staking amount is not 0!");
        isStaking[msg.sender] = true;
        StakingAmount[msg.sender] += msg.value;
        stakingTime[msg.sender] = block.timestamp;
        emit StakingEvent(msg.sender, true, "staking now!", msg.value);
    }

    function unstake() public payable{    
        require(!isStaking[msg.sender], 'Not staking!');
        uint256 stakingBalance = StakingAmount[msg.sender];
        isStaking[msg.sender] = false;
        stakingTime[msg.sender] = 0;
        StakingAmount[msg.sender] = 0;
        (bool call, bytes memory data) = _sender.call{value: stakingBalance}("");
        require(call, "error sending eth");
        emit UnstakeEvent(msg.sender, stakingBalance, isStaking[msg.sender], "Ended staking!");
    }
    
    function stakingRewards() public payable returns(uint256){
        require(!isStaking[msg.sender], 'Not staking!');
        uint256 _staker_time = stakingTime[msg.sender];
        uint256 _stakingAmount = StakingAmount[msg.sender];
        uint256 time_amount = block.timestamp - _staker_time;
        uint256 reward_payout = time_amount * _stakingAmount * rate/100000;
        emit RateEvent(time_amount, _staker_time, reward_payout, _stakingAmount);
        return reward_payout;
    }
    
    function play () public payable{
        require(msg.value == 10000000000000000, "Not enough to play.");
        gameStatus = GAME_STATUS.GAME_START;
        emit PlayEvent(msg.sender, gameStatus); 
    }

    function payotAmount(uint256 _score) public {
        require(gameStatus ==  GAME_STATUS.GAME_START);
        uint256 final_pay_out = _score / scoreDivider;
        payOutAmount[msg.sender] += final_pay_out;
        emit PayoutEvent(msg.sender, final_pay_out, game_status, _score);
        endGame();
    }

    function endGame() public{
        gameStatus = GAME_STATUS.GAME_ENDED;
        uint256 pay_out = payOutAmount[msg.sender];
        uint256 rate_reward = 0;
        if(isStaking[msg.sender]){
            rate_reward= stakingRewards();
            GTMToken.transfer(msg.sender, pay_out * rate_reward);
            emit EndedEvent(player, pay_out, rate_reward, game_status);
        }else{

            GTMToken.transfer(msg.sender, pay_out * 1e18);
            emit EndedEvent(player, pay_out, rate_reward, game_status);

        }
    }

}