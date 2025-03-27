// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract Huzaifa is ERC20, ERC20Permit {
    constructor() ERC20("Huzaifa", "hhr") ERC20Permit("Huziafa") {
        _mint(_msgSender(), 10000);
    }
}

contract staking is Huzaifa{
    Huzaifa public stakingToken;
    constructor(address _stakingToken) {
        stakingToken = Huzaifa(_stakingToken);
    }

    mapping (address => uint) public stakeAmount;
    mapping (address => uint) public stakeTime;
    function stake(uint256 stakeValue) public {
        require(stakeValue > 0, "Stake amount must be greater than 0");
        stakeAmount[msg.sender] += stakeValue;
        stakingToken.transfer(address(this), stakeValue);
        stakeTime[msg.sender]=block.timestamp;
    }
    function unstake() public {
        require(block.timestamp>=(stakeTime[msg.sender]));
        uint256 amount = stakeAmount[msg.sender];
        require (amount > 0, "You have no tokens to withdraw");
        require(block.timestamp>=(stakeTime[msg.sender])+10,"Cannot unstake before");
        
        stakingToken.transferFrom(address(this), msg.sender, amount);
    }
    
     
}