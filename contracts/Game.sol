pragma solidity ^0.8.1;
import "./GTMtoken.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Game{
    address public player;
    mapping(address => uint256) public score_mapping;
    mapping(address => uint256) public pay_out_amount;
    enum GAME_STATUS{GAME_START, GAME_ON, GAME_PENDING, GAME_ENDED}
    address public contract_address;
    uint256 public amount;
    uint256 public current_point;
    uint public playing_fee;
    GAME_STATUS game_status;
    uint256 public score_divider;
    
    event Payout(address, string);
    event Play(address, string);
    event Ended(address, uint256, GAME_STATUS);
    event New_payout(address, uint256, GAME_STATUS);
    event Constructor_event(address, uint256, GAME_STATUS);

    IERC20 public GTMToken;
    constructor(address _GTMTokenAddress) payable {
        game_status = GAME_STATUS.GAME_ON;
        player = msg.sender;
        playing_fee = 100000000000000000;
        score_divider = 1000;
        GTMToken = IERC20(_GTMTokenAddress);
        contract_address = address(this);
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

    function play () public payable{
        require(msg.value == 100000000000000000, "you must pay to play");
        game_status = GAME_STATUS.GAME_START;
        emit Play(msg.sender, "Game is on!"); 
    }

    /*  
        function get_score(uint256 _score) public view returns(uint256){
        score_mapping[msg.sender] = _score;
        return _score;}
    */

    /* function get_pay_amount(uint256 new_score) public returns(uint256){
        uint256 current_score = new_score;
          
        //emit Curr_payout(msg.sender, current_payout, game_status);
        return current_payout;
    } */

    function payout_amount(uint256 _score, address _gmttoken) public {
        require(game_status ==  GAME_STATUS.GAME_START);
        //uint256 final_pay_out= get_pay_amount(_score);

        //uint256 final_pay_out = _score / score_divider;
        emit New_payout(msg.sender, _score, game_status);
        emit Play(msg.sender, "hi daaawg");

        pay_out_amount[msg.sender] += _score;
        //end_game(msg.sender, _gmttoken);
    }

    function end_game(address _player, address _gmttoken) public{
        game_status = GAME_STATUS.GAME_ENDED;
        uint256 pay_out = pay_out_amount[_player];
        //GTMToken.transfer(msg.sender, pay_out);
        //GTMToken.allowance()
        GTMToken.transferFrom(contract_address, msg.sender, pay_out);
        emit Ended(player, pay_out, game_status);
    }

}