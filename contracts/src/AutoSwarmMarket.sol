// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {PostageStamp} from "storage-incentives/PostageStamp.sol";

import {IAutoSwarmMarket} from "./interfaces/IAutoSwarmMarket.sol";
import {IPostageStampLegacy} from "./interfaces/IPostageStampLegacy.sol";

// import {console} from "forge-std/console.sol";

contract AutoSwarmMarket is IAutoSwarmMarket, Ownable {
    // year of stampId
    mapping(bytes32 => uint256) public stampYear;

    // batchId of year
    mapping(uint256 => bytes32) public yearBatchId;

    // batchSize of year
    mapping(uint256 => uint256) public yearBatchSize;

    PostageStamp public postageStamp;
    IERC20 public bzzToken;

    uint256 public constant RATIO = 3;
    uint256 public constant SECONDS_PER_BLOCK = 5;
    uint256 public constant BUCKET_SIZE = 4096;
    uint8 public constant BUCKET_DEPTH = 16;
    uint256 public constant INITIAL_TTL = 30 days;
    uint8 public constant INITIAL_DEPTH = 23;

    uint256 public constant FIRST_YEAR = 2023;
    uint256 public nextYear = FIRST_YEAR;
    uint256 public currentYear = FIRST_YEAR;

    constructor(address postageStamp_) {
        _setPostage(postageStamp_);
    }

    function setCurrentYear(uint256 year) external override(IAutoSwarmMarket) onlyOwner {
        currentYear = year;
    }

    function setPostage(address postageStamp_) external override(IAutoSwarmMarket) onlyOwner {
        _setPostage(postageStamp_);
    }

    function buyBatch(uint256 year) external override(IAutoSwarmMarket) onlyOwner returns (bytes32 batchId) {
        require(year == nextYear++, "Buy next year first");

        bytes32 nonce = keccak256(abi.encode("Batch of year", year));

        bzzToken.approve(address(postageStamp), INITIAL_TTL << INITIAL_DEPTH);
        postageStamp.createBatch(address(this), INITIAL_TTL, INITIAL_DEPTH, BUCKET_DEPTH, nonce, false);

        batchId = yearBatchId[year] = keccak256(abi.encode(address(this), nonce));

        emit BuyBatch(batchId, year, INITIAL_DEPTH, INITIAL_TTL);
    }

    function extendsBatch(uint256 year, uint8 deltaDepth) external override(IAutoSwarmMarket) onlyOwner {
        uint256 ttl = getBatchTtl(year);
        require(ttl > 0, "Batch not valid");

        _diluteBatch(year, deltaDepth);

        uint256 mul = 1 << deltaDepth;

        _topUpBatch(year, (ttl * (mul - 1)) / mul);

        // ttl unchanged after dilute and topup
        assert(getBatchTtl(year) == ttl);

        emit UpdateBatch(year, getBatchDepth(year), ttl);
    }

    function buyStamp(uint256 year, bytes32 hash, uint256 size)
        external
        override(IAutoSwarmMarket)
        returns (bytes32 stampId)
    {
        uint256 ttl = getBatchTtl(year);
        require(ttl > 0, "Batch not valid");

        stampId = keccak256(abi.encode(year, hash, size));
        require(stampYear[stampId] == 0, "Stamp already exists");

        // balance = (ttl * postageStamp.lastPrice()) / SECONDS_PER_BLOCK;
        // buckets = size / BUCKET_SIZE;
        // bzzStampPrice = balance * buckets * RATIO;
        // mul and div in one operation to bypass rounding errors
        uint256 bzzStampPrice = (ttl * postageStamp.lastPrice() * size * RATIO) / (SECONDS_PER_BLOCK * BUCKET_SIZE);

        stampYear[stampId] = year;
        yearBatchSize[year] += size;

        require(yearBatchSize[year] * RATIO < getBatchSizeLimit(year), "No more space");

        require(bzzToken.transferFrom(msg.sender, address(this), bzzStampPrice), "Transfer failed");

        emit BuyStamp(stampId, year, size, hash);
    }

    function topUpBatch(uint256 year, uint256 ttl) public override(IAutoSwarmMarket) onlyOwner {
        _topUpBatch(year, ttl);

        emit UpdateBatch(year, getBatchDepth(year), ttl);
    }

    function diluteBatch(uint256 year, uint8 deltaDepth) public override(IAutoSwarmMarket) onlyOwner {
        _diluteBatch(year, deltaDepth);

        emit UpdateBatch(year, getBatchDepth(year) + deltaDepth, getBatchTtl(year));
    }

    function getBatchSizeLimit(uint256 year) public view override(IAutoSwarmMarket) returns (uint256) {
        return (BUCKET_SIZE << getBatchDepth(year)) / RATIO;
    }

    function getBatchDepth(uint256 year) public view override(IAutoSwarmMarket) returns (uint8) {
        return postageStamp.batchDepth(yearBatchId[year]);
    }

    function getBatchTtl(uint256 year) public view override(IAutoSwarmMarket) returns (uint256) {
        return postageStamp.remainingBalance(yearBatchId[year]);
    }

    function _topUpBatch(uint256 year, uint256 ttl) internal {
        require(getBatchTtl(year) > 0, "Batch not valid");

        bzzToken.approve(address(postageStamp), ttl << getBatchDepth(year));
        postageStamp.topUp(yearBatchId[year], ttl);
    }

    function _diluteBatch(uint256 year, uint8 deltaDepth) internal {
        require(getBatchTtl(year) > 0, "Batch not valid");

        postageStamp.increaseDepth(yearBatchId[year], getBatchDepth(year) + deltaDepth);
    }

    function _setPostage(address postageStamp_) internal {
        postageStamp = PostageStamp(payable(postageStamp_));
        bzzToken = IERC20(postageStamp.bzzToken());
    }
}
