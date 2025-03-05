// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

contract EventTicket {
    mapping(address => uint) public tickets;  // Lưu số vé của mỗi người
    uint public ticketPrice = 0.01 ether;  // Giá vé: 0.01 MON
    address public owner;  // Người tạo contract

    constructor() {
        owner = msg.sender;  // Gán owner là người deploy
    }

    function buyTicket(uint _numTickets) public payable {
        uint totalCost = _numTickets * ticketPrice;
        require(msg.value >= totalCost, "Khong du MON!");
        tickets[msg.sender] += _numTickets;  // Tăng số vé
    }

    function withdraw() public {
        require(msg.sender == owner, "Chi owner moi rut duoc!");
        payable(owner).transfer(address(this).balance);  // Rút hết MON về ví owner
    }
}