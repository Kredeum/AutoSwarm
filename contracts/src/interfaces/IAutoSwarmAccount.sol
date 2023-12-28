// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IAutoSwarmAccount {
    function swarmSize() external view returns (uint256);
    function swarmHash() external view returns (bytes32);
    function stampId() external view returns (bytes32);
    function marketOwner() external view returns (address);
    function implementation() external view returns (address);
    function getTopUpYearPrice() external view returns (uint256);
    function autoSwarmMarket() external view returns (address);

    function setAutoSwarmMarket(address) external;
    function createStamp(bytes32, uint256, uint256) external returns (bytes32);
    function updateStamp(bytes32, uint256) external;
    function topUp(uint256) external;
    function withdraw(address) external;
}
