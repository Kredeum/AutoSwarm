// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAutoSwarmAccount {
    function initialize(address) external;

    function buyYearStamp(uint256, bytes32, uint256, uint8) external returns (bytes32);
}
