// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPostageStampLegacy {
    function batches(bytes32) external returns (address, uint8, bool, uint256);
}
