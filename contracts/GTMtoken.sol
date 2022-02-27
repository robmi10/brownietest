pragma solidity ^0.8.1;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GTMtoken is ERC20 {
    address public admin;
    constructor(uint256 initialSupply) ERC20("gtm", "GTM") {
        _mint(msg.sender, initialSupply);
        admin == msg.sender;
    }
      
}