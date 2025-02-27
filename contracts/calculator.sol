// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;


contract lecture01 
{

    /* Variables can be public and prive
    Public variable can be accessed from anywhere/other contracts
    Meanwhile Private variable can only accessed from local contract */

    string private message = "Hello World";
    int256 val1;
    int256 val2;

    function sum() public view returns(int256) {
        return val1 + val2;
    }

    function multiply() public view returns(int256){
        return val1 * val2;
    }

    function subtract() public view returns(int256){
        return val1 - val2;
    }

    function divide() public view returns(int256){
        return val1 / val2;
    }

    // These function shows how to calculate using pure
    // In pure arguments are sent because it works on local context

    // function sum(int256 va1, int256 va2) public pure returns(int256) {
    //     return va1 + va2;
    // }

    // function multiply(int va1,int va2) public pure returns(int256){
    //     return va1*va2;
    // }

    // function subtract(int va1,int va2) public pure returns(int256){
    //     return va1-va2;
    // }

    // function divide(int va1,int va2) public pure returns(int256){
    //     return va1/va2;
    // }
    
    /** when a function is declared as view we can only read and not write */
    /** meanwhile in pure we cannot read and write, it stays constant */
    
    function returnMessage() public view returns (string memory){

        return message;
    }
    
}