// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Represents a batch of stamps.
 */
struct Batch {
    bytes32 batchId; // The unique identifier for the batch.
    uint256 year; // The year the batch was created.
    uint256 size; // The size of the batch.
}

/**
 * @dev Represents a stamp.
 */
struct Stamp {
    bytes32 stampId; // The unique identifier for the stamp.
    bytes32 batchId; // The batch the stamp belongs to.
    uint256 year; // The year the stamp was created.
    uint256 size; // The size of the stamp.
    bytes32 hash; // The hash of the stamp.
    uint256 time; // The time the stamp was created.
    uint256 price; // The price of the stamp.
}

/**
 * @title IAutoSwarmMarket
 * @dev This interface describes the functions exposed by the AutoSwarmMarket contract.
 */
interface IAutoSwarmMarket {
    /**
     * @dev Emitted when a stamp is bought.
     */
    event BuyStamp( // The ID of the bought stamp.
        // The ID of the batch the stamp belongs to.
        // The year the stamp was created.
        // The size of the stamp.
        // The hash of the stamp.
        // The time the stamp was created.
        // The price of the stamp.
        bytes32 indexed stampId,
        bytes32 indexed batchId,
        uint256 indexed year,
        uint256 size,
        bytes32 hash,
        uint256 time,
        uint256 price
    );
    /**
     * @dev Emitted when a batch is bought.
     */
    event BuyBatch( // The ID of the bought batch.
        // The year the batch was created.
        // The depth of the batch.
    bytes32 indexed batchId, uint256 indexed year, uint8 indexed depth, uint256 ttl); // The time to live of the batch.

    /**
     * @dev Emitted when a batch is updated.
     */
    event UpdateBatch( // The year the batch was created.
        // The depth of the batch.
    uint256 indexed year, uint8 indexed depth, uint256 indexed ttl); // The time to live of the batch.

    /**
     * @dev Returns the address of the BZZ token contract.
     */
    function bzzToken() external returns (address);

    /**
     * @dev Buys a stamp.
     * @param arg1 Description of the first argument.
     * @param arg2 Description of the second argument.
     * @param arg3 Description of the third argument.
     * @param arg4 Description of the fourth argument.
     * @return The ID of the bought stamp.
     */
    function buyStamp(uint256 arg1, bytes32 arg2, uint256 arg3, uint8 arg4) external returns (bytes32);
    /**
     * @dev Buys a batch.
     * @param arg Description of the argument.
     * @return The ID of the bought batch.
     */
    function buyBatch(uint256 arg) external returns (bytes32);

    /**
     * @dev Tops up a batch.
     * @param arg1 Description of the first argument.
     * @param arg2 Description of the second argument.
     */
    function topUpBatch(uint256 arg1, uint256 arg2) external;
    /**
     * @dev Dilutes a batch.
     * @param arg1 Description of the first argument.
     * @param arg2 Description of the second argument.
     */
    function diluteBatch(uint256 arg1, uint8 arg2) external;
    /**
     * @dev Extends a batch.
     * @param arg1 Description of the first argument.
     * @param arg2 Description of the second argument.
     */
    function extendsBatch(uint256 arg1, uint8 arg2) external;

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
