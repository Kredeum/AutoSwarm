// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {PostageStamp} from "@storage-incentives/PostageStamp.sol";

import {Stamp, Batch, IAutoSwarmMarket} from "@autoswarm/src/interfaces/IAutoSwarmMarket.sol";
import {IPostageStampLegacy} from "@autoswarm/src/interfaces/IPostageStampLegacy.sol";

// import {console} from "forge-std/console.sol";

contract AutoSwarmMarket is IAutoSwarmMarket, Ownable {
    // Stamp mapping
    mapping(bytes32 => Stamp) public stamp;

    // Batch mapping
    mapping(uint256 => Batch) public batch;

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
        require(!existsBatch(year), "Batch already exists");
        require(year == nextYear++, "Buy next year first");

        bytes32 nonce = keccak256(abi.encode("Batch of year", year));

        bzzToken.approve(address(postageStamp), INITIAL_TTL << INITIAL_DEPTH);
        postageStamp.createBatch(address(this), INITIAL_TTL, INITIAL_DEPTH, BUCKET_DEPTH, nonce, false);

        batch[year].batchId = batchId = keccak256(abi.encode(address(this), nonce));

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

    function buyStamp(uint256 year, bytes32 hash, uint256 size, uint8 tp)
        external
        override(IAutoSwarmMarket)
        returns (bytes32 stampId)
    {
        uint256 ttl = getBatchTtl(year);
        require(ttl > 0, "Batch not valid");

        bytes32 previousStampId = getStampId(year - 1, hash, size, tp);
        require(year == currentYear || previousStampId != bytes32(0));

        stampId = getStampId(year, hash, size, tp);
        require(stamp[stampId].stampId == bytes32(0), "Stamp already exists");

        bytes32 batchId = batch[year].batchId;

        uint256 newSize = batch[year].size + size;
        batch[year].size = newSize;

        require(newSize * RATIO < getBatchSizeLimit(year), "No more space");

        // balance = (ttl * postageStamp.lastPrice()) / SECONDS_PER_BLOCK;
        // buckets = size / BUCKET_SIZE;
        // bzz = balance * buckets * RATIO;
        // mul and div in one operation to bypass rounding errors
        uint256 bzz = (ttl * postageStamp.lastPrice() * size * RATIO) / (SECONDS_PER_BLOCK * BUCKET_SIZE);

        stamp[stampId] = Stamp(stampId, batchId, year, size, hash, block.timestamp, bzz);

        require(bzzToken.transferFrom(msg.sender, address(this), bzz), "Transfer failed");

        emit BuyStamp(stampId, batchId, year, size, hash, block.timestamp, bzz);
    }

    function getStamp(bytes32 stampId) public view returns (Stamp memory) {
        return stamp[stampId];
    }

    function getBatch(uint256 year) public view returns (Batch memory) {
        return batch[year];
    }

    function existsBatch(uint256 year) public view returns (bool) {
        return batch[year].batchId != bytes32(0);
    }

    function getStampId(uint256 year, bytes32 hash, uint256 size, uint8 tp)
        public
        pure
        override(IAutoSwarmMarket)
        returns (bytes32)
    {
        return keccak256(abi.encode(year, hash, size, tp));
    }

    function withdraw(address token) external override(IAutoSwarmMarket) onlyOwner {
        if (token == address(0)) {
            (bool success,) = msg.sender.call{value: address(this).balance}("");
            require(success, "Withdraw failed!");
        } else {
            IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
        }
    }

    function topUpBatch(uint256 year, uint256 ttl) external override(IAutoSwarmMarket) onlyOwner {
        _topUpBatch(year, ttl);

        emit UpdateBatch(year, getBatchDepth(year), ttl);
    }

    function diluteBatch(uint256 year, uint8 deltaDepth) external override(IAutoSwarmMarket) onlyOwner {
        _diluteBatch(year, deltaDepth);

        emit UpdateBatch(year, getBatchDepth(year) + deltaDepth, getBatchTtl(year));
    }

    function getBatchSizeLimit(uint256 year) public view override(IAutoSwarmMarket) returns (uint256) {
        return (BUCKET_SIZE << getBatchDepth(year)) / RATIO;
    }

    function getBatchDepth(uint256 year) public view override(IAutoSwarmMarket) returns (uint8) {
        return postageStamp.batchDepth(batch[year].batchId);
    }

    function getBatchTtl(uint256 year) public view override(IAutoSwarmMarket) returns (uint256) {
        return postageStamp.remainingBalance(batch[year].batchId);
    }

    function _topUpBatch(uint256 year, uint256 ttl) internal {
        require(getBatchTtl(year) > 0, "Batch not valid");

        bzzToken.approve(address(postageStamp), ttl << getBatchDepth(year));
        postageStamp.topUp(batch[year].batchId, ttl);
    }

    function _diluteBatch(uint256 year, uint8 deltaDepth) internal {
        require(getBatchTtl(year) > 0, "Batch not valid");

        postageStamp.increaseDepth(batch[year].batchId, getBatchDepth(year) + deltaDepth);
    }

    function _setPostage(address postageStamp_) internal {
        postageStamp = PostageStamp(payable(postageStamp_));
        bzzToken = IERC20(postageStamp.bzzToken());
    }
}
