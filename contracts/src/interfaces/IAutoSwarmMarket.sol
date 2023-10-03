// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAutoSwarmMarket {
    function buyBatch(uint256) external returns (bytes32);
    function topUpBatch(uint256, uint256) external returns (uint256);
    function diluteBatch(uint256, uint8) external returns (uint256);
    function extendsBatch(uint256, uint8) external;

    function buyStamp(uint256, bytes32, uint256) external returns (bytes32);

    function getBatchDepth(uint256) external view returns (uint8);
    function getBatchTtl(uint256) external view returns (uint256);
    function getBatchSizeLimit(uint256) external view returns (uint256);
}
