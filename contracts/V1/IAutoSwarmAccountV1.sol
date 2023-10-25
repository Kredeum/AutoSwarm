// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAutoSwarmAccountV1 {
    function initialize(address) external;
    function buyYearStamp(uint256, bytes32, uint256, uint8) external returns (bytes32);
    function withdraw(address) external;
}
