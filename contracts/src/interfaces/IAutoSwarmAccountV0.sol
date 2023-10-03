// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAutoSwarmAccount {
    function initialize(address) external;
    function stampsIncreaseDepth(bytes32, uint8) external;
    function withdraw(address) external;
    function stampsBuy(uint256, uint8) external returns (bytes32);
    function stampsTopUp(bytes32, uint256) external;
}
