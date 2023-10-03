// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {PostageStamp} from "storage-incentives/PostageStamp.sol";

import {IAutoSwarmMarket} from "./interfaces/IAutoSwarmMarket.sol";
import {IPostageStampLegacy} from "./interfaces/IPostageStampLegacy.sol";

// import {console} from "forge-std/console.sol";

contract AutoSwarmMarket is IAutoSwarmMarket, Ownable {
    mapping(bytes32 => uint256) public stampYear;
    mapping(uint256 => bytes32) public yearBatchId;
    mapping(uint256 => uint256) public batchSize;

    PostageStamp public postageStamp;
    IERC20 public bzzToken;
    uint256 public constant RATIO = 3;
    uint256 public constant SECONDS_PER_BLOCK = 5;
    uint256 public constant BUCKET_SIZE = 4096;
    uint8 public constant BUCKET_DEPTH = 16;
    uint256 public constant INITIAL_TTL = 30 days;
    uint8 public constant INITIAL_DEPTH = 23;

    uint256 public constant FIRST_PERIOD = 2023; // year 2023
    uint256 public constant PERIOD = 3600 * 24 * 365 / SECONDS_PER_BLOCK; // number of blocks in 1 year

    uint256 public nextYear = FIRST_PERIOD;

    constructor(address postageStamp_) {
        postageStamp = PostageStamp(payable(postageStamp_));
        bzzToken = IERC20(postageStamp.bzzToken());
    }

    function buyBatch(uint256 year) external override(IAutoSwarmMarket) returns (bytes32) {
        require(year == nextYear++, "Buy next year first");

        bytes32 nonce = keccak256(abi.encode("Batch of year", year));

        bzzToken.approve(address(postageStamp), INITIAL_TTL << INITIAL_DEPTH);
        postageStamp.createBatch(address(this), INITIAL_TTL, INITIAL_DEPTH, BUCKET_DEPTH, nonce, false);

        return yearBatchId[year] = keccak256(abi.encode(address(this), nonce));
    }

    function extendsBatch(uint256 year, uint8 newDepth) external override(IAutoSwarmMarket) {
        uint256 ttl = getBatchTtl(year);
        require(ttl > 0, "Batch not valid");

        uint8 oldDepth = getBatchDepth(year);
        require(newDepth > oldDepth, "Batch depth not increased");

        uint256 mul = 1 << (newDepth - oldDepth);

        diluteBatch(year, newDepth);

        // topup mul time minus 1/mul already
        // => 1 - 1/mul = (mul-1)/mul
        topUpBatch(year, (ttl * (mul - 1)) / mul);

        // ttl unchanged after dilute and topup
        assert(getBatchTtl(year) == ttl);
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
        batchSize[year] += size;

        require(batchSize[year] * RATIO < getBatchSizeLimit(year), "No more space");

        require(bzzToken.transferFrom(msg.sender, address(this), bzzStampPrice), "failed transfer");
    }

    function topUpBatch(uint256 year, uint256 ttl) public override(IAutoSwarmMarket) returns (uint256 newTtl) {
        require(getBatchTtl(year) > 0, "Batch not valid");

        uint8 depth = getBatchDepth(year);

        bzzToken.approve(address(postageStamp), ttl << depth);
        postageStamp.topUp(yearBatchId[year], ttl);

        newTtl = getBatchTtl(year);
    }

    function diluteBatch(uint256 year, uint8 newDepth) public override(IAutoSwarmMarket) returns (uint256 newTtl) {
        require(getBatchTtl(year) > 0, "Batch not valid");

        postageStamp.increaseDepth(yearBatchId[year], newDepth);

        newTtl = getBatchTtl(year);
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
}
