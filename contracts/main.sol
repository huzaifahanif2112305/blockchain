// SPDX-License-Identifier: MIT
pragma solidity >0.8.2<0.9.0;

contract main 
{
    receive() external payable { }
    address payable owner=payable (msg.sender);
    uint public contractBalance = address(this).balance;
    
    function sendEther() public payable {
        require(msg.value >=1 ether,"not enough Money");
        payable (owner).transfer(address(this).balance);
    }
}