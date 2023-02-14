
pragma solidity ^0.8.1;
import "./GTMtoken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Game{
    address public player;

    mapping(address => uint256) public StakingAmount;
    mapping(address => bool) public isStaking;
    mapping(address => uint256) public stakingTime;

    enum GAME_STATUS{GAME_START, GAME_ON, GAME_PENDING, GAME_ENDED}

    GAME_STATUS gameStatus;
    uint256 public scoreDivider;
    uint256 public rate = 2;
    uint256 rateReward;
    uint256 rateCalc;
    uint256 stakingAmount;
    
    event PlayEvent(address indexed _user, bool indexed _status);
    event EndedEvent(address indexed _from, uint256 indexed _amount, uint256  indexed _reward, uint256 _calc, uint256 _calcWei);
    event PayoutEvent(address indexed _from, uint256 indexed _amount, uint256 indexed _score, GAME_STATUS);
    event RateEvent(uint256 indexed _rate, uint256 indexed _time,  uint256 indexed _input, uint256  _stakingAmount);
    event StakingEvent(address indexed _staker, bool indexed _on, string indexed _message, uint256  _value);
    event UnstakeEvent(address  _staker, uint256 indexed _amount, bool indexed _on, string  _message);
    event StakeStatusEvent(address _staker, bool _stake_status, uint256 _amount ,string _message, uint256 _time_stamp);

    IERC20 public GTMToken;
    constructor(address _GTMTokenAddress) payable {
        gameStatus = GAME_STATUS.GAME_ON;
        player = msg.sender;
        scoreDivider = 86;
        GTMToken = IERC20(_GTMTokenAddress);
    }

    function stake() public payable{
        require(!isStaking[msg.sender], 'Already staking!');
        isStaking[msg.sender] = true;
        StakingAmount[msg.sender] += msg.value;
        stakingTime[msg.sender] = block.timestamp;
        emit StakingEvent(msg.sender, true, "staking now!", msg.value);
    }

    function unstake() public payable{    
        require(isStaking[msg.sender], 'Not staking!');
        uint256 stakingBalance = StakingAmount[msg.sender];
        isStaking[msg.sender] = false;
        stakingTime[msg.sender] = 0;
        StakingAmount[msg.sender] = 0;
        (bool call, bytes memory data) = msg.sender.call{value: stakingBalance}("");
        require(call, "error sending eth");
        emit UnstakeEvent(msg.sender, stakingBalance, isStaking[msg.sender], "Ended staking!");
    }
    
    function stakingRewards(address _sender) public payable returns(uint256, uint256, uint256){
        require(isStaking[_sender], 'Not staking!');
        uint256 stakeTime = stakingTime[_sender];
        stakingAmount = StakingAmount[_sender];
        uint256 duration = (block.timestamp - stakeTime) / 60 / 60 * 24;
        rateCalc = 1 + (rate * 1.0 / 100 * duration / 365);
        uint256 rewardPayout = stakingAmount/100 + (rateCalc * 1e18);
        return (rewardPayout, rateCalc * 1e18, stakingAmount);
    }
        
    function play () public payable{
        require(msg.value == 10000000000000000, "Not enough to play.");
        gameStatus = GAME_STATUS.GAME_START;
        emit PlayEvent(msg.sender, true); 
    }

    function payotAmount(uint256 _score) public {
        require(gameStatus ==  GAME_STATUS.GAME_START);
        uint256 final_pay_out = _score / scoreDivider;
        emit PayoutEvent(msg.sender, final_pay_out,  _score, gameStatus);
        endGame(final_pay_out);
    }

    function endGame(uint256 _payout) public{
        gameStatus = GAME_STATUS.GAME_ENDED;
        if(isStaking[msg.sender]){
            (rateReward, rateCalc, stakingAmount) = stakingRewards(msg.sender);
            GTMToken.transfer(msg.sender, (_payout * rateReward ) / 1e18);
            emit EndedEvent(player,  (_payout * rateReward ) / 1e18, rateReward, _payout * rateReward, (_payout * rateReward ) / 1e18);
        }else{
            GTMToken.transfer(msg.sender, _payout);
            emit EndedEvent(player, _payout, rateReward, _payout * rateReward, (_payout * rateReward) / 1e18);
        }
    }

}