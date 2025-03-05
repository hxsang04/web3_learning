// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;
contract Test {
    uint public number = 42;
    function setNumber(uint _number) public {
        number = _number;
    }
}