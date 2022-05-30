pragma solidity ^0.8.1;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WETHtoken is ERC20 {
    address public admin;
    constructor(uint256 initialSupply) ERC20("MOCKweth", "WETH") {
        _mint(msg.sender, initialSupply);
        admin == msg.sender;
    }
      
}