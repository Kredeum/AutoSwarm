// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.19;

interface IPostageStamp {
    struct Batch {
        address owner;
        uint8 depth;
        uint8 bucketDepth;
        bool immutableFlag;
        uint256 normalisedBalance;
        uint256 lastUpdatedBlockNumber;
    }

    function lastPrice() external view returns (uint64);

    function createBatch(address, uint256, uint8, uint8, bytes32, bool) external returns(bytes32);
    function increaseDepth(bytes32, uint8) external;
    function topUp(bytes32, uint256) external;

    function bzzToken() external returns (address);

    function withdraw(address beneficiary) external;

    function validChunkCount() external view returns (uint256);

    function batchOwner(bytes32 _batchId) external view returns (address);
    function batchDepth(bytes32 _batchId) external view returns (uint8);
    function batchBucketDepth(bytes32 _batchId) external view returns (uint8);

    function remainingBalance(bytes32 _batchId) external view returns (uint256);
    function minimumInitialBalancePerChunk() external view returns (uint256);

    function setPrice(uint256 _price) external;

    function batches(bytes32) external view returns (address, uint8, uint8, bool, uint256, uint256);
}
