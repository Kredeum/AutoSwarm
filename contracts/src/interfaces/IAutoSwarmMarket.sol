// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IERC20} from "./IERC20.sol";
import {IPostageStamp} from "./IPostageStamp.sol";

interface IAutoSwarmMarket {
    event BuyBatch(bytes32 indexed batchId, uint256 indexed index, uint8 indexed depth, uint256 ttl);
    event UpdateBatch(bytes32 indexed index, uint8 indexed depth, uint256 indexed ttl);
    event UpdateStampsUnitPrice(uint256 unitPrice);

    struct Stamp {
        address owner;
        bytes32 hash;
        uint256 size;
    }

    function buyBatch() external returns (bytes32 batchId);
    function extendsBatch(bytes32, uint8) external;

    function sync() external;
    function setUnitPrice(uint256) external;

    function bzzToken() external view returns (IERC20);
    function getUnitYearPrice() external view returns (uint256);
    function getYearPrice(uint256) external view returns (uint256);
    function getMbSize(uint256) external pure returns (uint256);
}
