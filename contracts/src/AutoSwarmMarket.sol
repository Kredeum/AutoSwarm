// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {PostageStamp} from "storage-incentives/PostageStamp.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract AutoSwarmMarket is Ownable {
    bytes32[] public batchIds;
    PostageStamp public postageStamp;
    IERC20 public bzzToken;
    uint256 constant RATIO = 3;
    uint256 constant SECONDS_PER_BLOCK = 5;
    uint256 constant BUCKET_SIZE = 4096;

    constructor(address postageStamp_) {
        postageStamp = PostageStamp(payable(postageStamp_));
        bzzToken = IERC20(postageStamp.bzzToken());
    }

    function getTtlFromBalance(uint256 balance) public view returns (uint256 ttl) {
        ttl = (balance * SECONDS_PER_BLOCK) / postageStamp.lastPrice();
    }

    function getBalanceFromTtl(uint256 ttl) public view returns (uint256 balance) {
        balance = (ttl * postageStamp.lastPrice()) / SECONDS_PER_BLOCK;
    }

    function getBucketsFromSize(uint256 size) public pure returns (uint256 buckets) {
        buckets = size / BUCKET_SIZE;
    }

    function addBatch(bytes32 batchId) external onlyOwner returns (uint256) {
        require(validBatch(batchId), "Not a valid batch");

        batchIds.push(batchId);
        return batchIds.length;
    }

    function bzzRemainingBalance(bytes32 batchId) public view returns (uint256) {
        uint8 depth = postageStamp.batchDepth(batchId);
        uint256 remainingBalance = postageStamp.remainingBalance(batchId);

        return remainingBalance << depth;
    }

    function validBatch(bytes32 batchId) public view returns (bool) {
        (address owner, uint8 depth, uint8 bucketDepth,, uint256 normalisedBalance, uint256 lastUpdatedBlockNumber) =
            postageStamp.batches(batchId);

        return (owner != address(0)) && (depth > bucketDepth) && (bucketDepth >= 16) && (normalisedBalance > 0)
            && (lastUpdatedBlockNumber > 0);
    }

    function buyStamp(uint256 size, uint256 ttl) external {
        _buyStamp(getBucketsFromSize(size), getBalanceFromTtl(ttl));
    }

    function _buyStamp(uint256 buckets, uint256 balance) internal {
        uint256 bzzStampPrice = balance * buckets * RATIO;
        require(bzzToken.transferFrom(msg.sender, address(this), bzzStampPrice), "failed transfer");
    }
}
