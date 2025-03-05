const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("EventTicketModule", (m) => {
    const ticket = m.contract("EventTicket");
    return { ticket };
});