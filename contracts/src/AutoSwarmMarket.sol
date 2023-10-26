// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IAutoSwarmMarket, IPostageStamp, IERC20} from "./interfaces/IAutoSwarmMarket.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {console} from "forge-std/console.sol";

contract AutoSwarmMarket is IAutoSwarmMarket, Ownable {
    bytes32[] public batchIds;

    // uint256 public currentBatchIndex;
    // bytes32 public currentBatchId;
    // IPostageStamp.Batch public currentBatch;

    // mimic PostageStamp batch calculation, for stamp calculation
    uint256 public stampsTotalPaid;
    uint256 public stampsUnitPrice;
    uint256 public stampsBlockUpdate;

    IPostageStamp internal _postageStamp;
    IERC20 public bzzToken;

    uint256 internal constant _INITIAL_TTL = 30 days;
    uint8 internal constant _INITIAL_DEPTH = 23;
    uint8 internal constant _BUCKET_DEPTH = 16;

    uint256 internal constant _BLOCKS_PER_SECOND = 5;
    uint256 internal constant _SECOND_PER_YEAR = 365 * 24 * 3600;
    uint256 internal constant _BLOCKS_PER_YEAR = _SECOND_PER_YEAR / _BLOCKS_PER_SECOND;

    uint256 public constant AUTOSWARM_UNIT = 1024 ** 2; // 1 Mo

    constructor(address postageStamp_) {
        _postageStamp = IPostageStamp(payable(postageStamp_));
        bzzToken = IERC20(_postageStamp.bzzToken());

        stampsBlockUpdate = block.number;
        setUnitPrice(2e8);
    }

    function setUnitPrice(uint256 unitPrice) public override(IAutoSwarmMarket) onlyOwner {
        stampsTotalPaid = _currentTotalPaid();
        stampsUnitPrice = unitPrice;
        stampsBlockUpdate = block.number;

        emit UpdateStampsUnitPrice(stampsUnitPrice);
    }

    function getUnitYearPrice() public view override(IAutoSwarmMarket) onlyOwner returns (uint256) {
        return stampsUnitPrice * _BLOCKS_PER_YEAR;
    }

    function getYearPrice(uint256 size) public view override(IAutoSwarmMarket) returns (uint256) {
        return stampsUnitPrice * _BLOCKS_PER_YEAR * getMbSize(size);
    }

    function getMbSize(uint256 size) public pure override(IAutoSwarmMarket) returns (uint256) {
        // ceiled integer div (instead of floored)
        return (size + AUTOSWARM_UNIT - 1) / AUTOSWARM_UNIT;
    }

    function syncCurrent() internal {
        // currentBatchIndex = batchIds.length - 1;
        // currentBatchId = batchIds[currentBatchIndex];
        // currentBatch = _postageStamp.batches(currentBatchId);
    }

    function sync() public override(IAutoSwarmMarket) {
        // buyBatch or diluteBatch...
    }

    function buyBatch() external override(IAutoSwarmMarket) onlyOwner returns (bytes32 batchId) {
        uint256 index = batchIds.length;
        bytes32 nonce = keccak256(abi.encode("Batch #index", index));

        batchId = keccak256(abi.encode(address(this), nonce));

        bzzToken.approve(address(_postageStamp), _INITIAL_TTL << _INITIAL_DEPTH);
        _postageStamp.createBatch(address(this), _INITIAL_TTL, _INITIAL_DEPTH, _BUCKET_DEPTH, nonce, false);

        batchIds.push(batchId);

        emit BuyBatch(batchId, index, _INITIAL_DEPTH, _INITIAL_TTL);

        syncCurrent();
    }

    function extendsBatch(bytes32 batchId, uint8 deltaDepth) external override(IAutoSwarmMarket) onlyOwner {
        uint256 ttl = _postageStamp.remainingBalance(batchId);
        require(ttl > 0, "Batch not valid");

        uint8 newDepth = _postageStamp.batchDepth(batchId) + deltaDepth;

        _diluteBatch(batchId, newDepth);
        assert(_postageStamp.batchDepth(batchId) == newDepth);

        uint256 mul = 1 << deltaDepth;
        uint256 newTtl = (ttl * (mul - 1)) / mul;

        _topUpBatch(batchId, newTtl);
        assert(_postageStamp.remainingBalance(batchId) == ttl);

        emit UpdateBatch(batchId, newDepth, ttl);
    }

    function _currentTotalPaid() internal view returns (uint256) {
        uint256 blocks = block.number - stampsBlockUpdate;
        uint256 stampIncreasePaid = stampsUnitPrice * blocks;
        return stampsTotalPaid + stampIncreasePaid;
    }

    function _diluteBatch(bytes32 batchId, uint8 depth) internal {
        _postageStamp.increaseDepth(batchId, depth);
    }

    function _topUpBatch(bytes32 batchId, uint256 ttl) internal {
        bzzToken.approve(address(_postageStamp), ttl << _postageStamp.batchDepth(batchId));
        _postageStamp.topUp(batchId, ttl);
    }
}
