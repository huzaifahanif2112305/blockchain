// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract lecture01 
{
    
    int256 public a=5;


    function increment() public returns(int256) {
        return ++a;
    }
    
    function decrement() public returns(int256) {
        return --a;
    }

    bool public Found = true;

    function check() public returns(bool){
        if (Found == true){
            Found = false;
        }
        else {
            Found = true;
        }
        return Found;
    }



    function even_odd(int256 num1, string memory message) public pure returns(string memory){
        num1  = num1 % 2;
        if (num1 == 0){
            message = "It's an even number";
        }
        else{
            message = "It's an odd number";
        }
        return message;
    }

    function check_even(int256 num1) public pure{
        
        require(num1 % 2 == 0 , "It's an odd number");
    }
    
    // we cannot concat due to security concerns as when a transaction occurs it is hashed and if concat is applied it won't be 
    // possible to decrypt the hashed message

    string newString;

    // we should avoid concat but when necessary this is the way

    function concat(string memory str1, string memory str2) public returns(string memory){
        newString = string(abi.encodePacked(str1,str2));
        return newString;
    }


    //msg.sender --> any address who initiates the transactions which can be EOA(Externally owned accounts, owned by human)
    // and contract(an address owned by the developer)  
    
    address _owner = msg.sender;

    function message() public view returns(address){
        return _owner;
    }


}