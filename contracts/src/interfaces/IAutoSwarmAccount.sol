// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IAutoSwarmAccount {
    function autoSwarmMarket() external view returns (address);

    function topUp(uint256) external;

    function swarmSize() external view returns (uint256);
    function swarmHash() external view returns (bytes32);

    function setAutoSwarm(uint256 swarmSize, bytes32 swarmHash) external;
    function setAutoSwarmStamp(uint256 swarmSize, bytes32 swarmHash, uint256 bzzAmount) external;

    function getTopUpYearPrice() external view returns (uint256);
}
