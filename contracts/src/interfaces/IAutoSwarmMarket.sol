// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct Batch {
    bytes32 batchId;
    uint256 year;
    uint256 size;
}

struct Stamp {
    bytes32 stampId;
    bytes32 batchId;
    uint256 year;
    uint256 size;
    bytes32 hash;
    uint256 time;
    uint256 price;
}

interface IAutoSwarmMarket {
    event BuyStamp(
        bytes32 indexed stampId,
        bytes32 indexed batchId,
        uint256 indexed year,
        uint256 size,
        bytes32 hash,
        uint256 time,
        uint256 price
    );
    event BuyBatch(bytes32 indexed batchId, uint256 indexed year, uint8 indexed depth, uint256 ttl);
    event UpdateBatch(uint256 indexed year, uint8 indexed depth, uint256 indexed ttl);

    function bzzToken() external returns (address);

    function buyStamp(uint256, bytes32, uint256, uint8) external returns (bytes32);
    function buyBatch(uint256) external returns (bytes32);

    function topUpBatch(uint256, uint256) external;
    function diluteBatch(uint256, uint8) external;
    function extendsBatch(uint256, uint8) external;

    function withdraw(address token) external;

    function setPostage(address) external;
    function setCurrentYear(uint256) external;

    function currentYear() external view returns (uint256);
    function nextYear() external view returns (uint256);

    function getBatchDepth(uint256) external view returns (uint8);
    function getBatchTtl(uint256) external view returns (uint256);
    function getBatchSizeLimit(uint256) external view returns (uint256);

    function getStampId(uint256, bytes32, uint256) external pure returns (bytes32);
    function getStampPrice(uint256, uint256) external view returns (uint256);
}
