// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {PostageStamp} from "storage-incentives/PostageStamp.sol";

import {Stamp, Batch, IAutoSwarmMarket} from "./interfaces/IAutoSwarmMarket.sol";
import {IPostageStampLegacy} from "./interfaces/IPostageStampLegacy.sol";

import {console} from "forge-std/console.sol";

contract AutoSwarmMarket is IAutoSwarmMarket, Ownable {
    mapping(bytes32 => Stamp) public stamp;

    mapping(uint256 => Batch) public batch;

    PostageStamp public postageStamp;
    address public bzzToken;

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

        batch[year].batchId = batchId = keccak256(abi.encode(address(this), nonce));

        IERC20(bzzToken).approve(address(postageStamp), INITIAL_TTL << INITIAL_DEPTH);
        postageStamp.createBatch(address(this), INITIAL_TTL, INITIAL_DEPTH, BUCKET_DEPTH, nonce, false);

        emit BuyBatch(batchId, year, INITIAL_DEPTH, INITIAL_TTL);
    }

    function extendsBatch(uint256 year, uint8 deltaDepth) external override(IAutoSwarmMarket) onlyOwner {
        uint256 ttl = getBatchTtl(year);
        require(ttl > 0, "Batch not valid");

        _diluteBatch(year, deltaDepth);

        uint256 mul = 1 << deltaDepth;
        uint256 newTtl = (ttl * (mul - 1)) / mul;

        _topUpBatch(year, newTtl);

        assert(getBatchTtl(year) == ttl);

        emit UpdateBatch(year, getBatchDepth(year), ttl);
    }

    function getStampPrice(uint256 year, uint256 size) public view override(IAutoSwarmMarket) returns (uint256 bzz) {
        uint256 ttl = getBatchTtl(year);
        require(ttl > 0, "Batch Year not valid");

        uint256 price = 1; // postageStamp.lastPrice();

        // Calculate the balance of the batch
        // uint256 balance = (ttl * postageStamp.lastPrice()) / SECONDS_PER_BLOCK;
        // Calculate the number of buckets required for the given size
        // uint256 buckets = size / BUCKET_SIZE;
        // Calculate the price of the stamp in BZZ tokens
        // bzz = balance * buckets * RATIO;
        // mul and div in one operation to bypass rounding errors
        bzz = (ttl * price * size * RATIO) / (SECONDS_PER_BLOCK * BUCKET_SIZE);
    }

    function buyStamp(uint256 year, bytes32 hash, uint256 size, uint8 n)
        external
        override(IAutoSwarmMarket)
        returns (bytes32 stampId)
    {
        bytes32 previousStampId = getStampId(year - 1, hash, size);
        require(year == currentYear || previousStampId != bytes32(0));

        stampId = getStampId(year, hash, size);
        require(stamp[stampId].stampId == bytes32(0), "Stamp already exists");

        uint256 newSize = batch[year].size + size;
        require(newSize * RATIO < getBatchSizeLimit(year), "No more space");

        uint256 bzz = getStampPrice(year, size);

        bytes32 batchId = batch[year].batchId;

        stamp[stampId] = Stamp(stampId, batchId, year, size, hash, block.number, bzz);

        require(IERC20(bzzToken).transferFrom(msg.sender, address(this), bzz), "Transfer failed");

        emit BuyStamp(stampId, batchId, year, size, hash, block.number, bzz);

        return stampId;
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

    function getStampId(uint256 year, bytes32 hash, uint256 size)
        public
        pure
        override(IAutoSwarmMarket)
        returns (bytes32)
    {
        return keccak256(abi.encode(year, hash, size));
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

    function getOneYearAmount(uint256 year) public view override(IAutoSwarmMarket) returns (uint256) {    }

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

        IERC20(bzzToken).approve(address(postageStamp), ttl << getBatchDepth(year));
        postageStamp.topUp(batch[year].batchId, ttl);
    }

    function _diluteBatch(uint256 year, uint8 deltaDepth) internal {
        require(getBatchTtl(year) > 0, "Batch not valid");

        postageStamp.increaseDepth(batch[year].batchId, getBatchDepth(year) + deltaDepth);
    }

    function _setPostage(address postageStamp_) internal {
        postageStamp = PostageStamp(payable(postageStamp_));
        bzzToken = postageStamp.bzzToken();
    }
}
