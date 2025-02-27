// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import"@openzeppelin/contracts/token/ERC20/ERC20.sol";
import"@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";


contract huzaifa is ERC20, ERC20Permit{
constructor() ERC20("Huzaifa","hhr") ERC20Permit("huzaifa"){
    
}
}
