// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAutoSwarmMarket {
    event BuyStamp(bytes32 indexed stampId, uint256 indexed year, uint256 indexed size, bytes32 hash);
    event BuyBatch(bytes32 indexed batchId, uint256 indexed year, uint8 indexed depth, uint256 ttl);
    event UpdateBatch(uint256 indexed year, uint8 indexed depth, uint256 indexed ttl);

    function buyStamp(uint256, bytes32, uint256) external returns (bytes32);
    function buyBatch(uint256) external returns (bytes32);

    function topUpBatch(uint256, uint256) external;
    function diluteBatch(uint256, uint8) external;
    function extendsBatch(uint256, uint8) external;

    function setPostage(address) external;
    function setCurrentYear(uint256) external;

    function getBatchDepth(uint256) external view returns (uint8);
    function getBatchTtl(uint256) external view returns (uint256);
    function getBatchSizeLimit(uint256) external view returns (uint256);
}
