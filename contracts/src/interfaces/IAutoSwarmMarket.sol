// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IERC20} from "./IERC20.sol";
import {IPostageStamp} from "./IPostageStamp.sol";

interface IAutoSwarmMarket {
    event BuyBatch(bytes32 indexed batchId, uint256 indexed index, uint8 indexed depth, uint256 ttl);
    event UpdateBatch(bytes32 indexed index, uint8 indexed depth, uint256 indexed ttl);
    event UpdateStampsUnitPrice(uint256 unitPrice);

    function createStamp(bytes32 swarmHash, uint256 swarmSize, uint256 bzzAmount) external returns (bytes32 stampId);
    function topUpStamp(bytes32 stampId, uint256 bzzAmount) external;

    function newBatch(address) external returns (bytes32 batchId);
    function newBatch(address, uint256) external returns (bytes32 batchId);
    function extendsBatch(bytes32, uint8) external;

    function sync() external;
    function setUnitPrice(uint256) external;

    function bzzToken() external view returns (IERC20);
    function getStampUnitPriceOneYear() external view returns (uint256);
    function getStampPriceOneYear(uint256) external view returns (uint256);
    function getMbSize(uint256) external pure returns (uint256);
}
