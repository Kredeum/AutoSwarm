// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IAutoSwarmMarket, IPostageStamp, IERC20} from "./interfaces/IAutoSwarmMarket.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {console} from "forge-std/console.sol";

contract AutoSwarmMarket is IAutoSwarmMarket, Ownable {
    struct Stamp {
        address owner;
        bytes32 hash;
        uint256 size;
        uint256 endBlock;
    }

    bytes32[] public batchIds;
    IPostageStamp.Batch public previousBatch;
    IPostageStamp.Batch public currentBatch;

    bytes32[] public stampIds;
    mapping(bytes32 => Stamp) public stamps;

    // mimic PostageStamp batch calculation, for stamp calculation
    uint256 public stampsTotalPaid;
    uint256 public stampsUnitPrice;
    uint256 public stampsBlockUpdate;

    IPostageStamp internal _postageStamp;
    IERC20 public bzzToken;

    uint256 internal constant _EXPIRATION_TTL = 7 days;
    uint256 internal constant _INITIAL_TTL = 30 days;
    uint8 internal constant _INITIAL_DEPTH = 23;
    uint8 internal constant _BUCKET_DEPTH = 16;

    uint256 internal constant _SECONDS_PER_BLOCK = 5;
    uint256 internal constant _SECOND_PER_YEAR = 365 * 24 * 3600;
    uint256 internal constant _BLOCKS_PER_YEAR = _SECOND_PER_YEAR / _SECONDS_PER_BLOCK;

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

    function getActiveStampIds() public view returns (uint256[] memory activeStampIds) {
        uint256 len = stampIds.length;

        for (uint256 index; index < len; index++) {
            bytes32 stampId = stampIds[index];
            if (stamps[stampId].endBlock > block.number) {
                activeStampIds.push(stampId);
            }
        }
    }

    function setNewBatch(bytes32 batchId) internal {
        previousBatch = currentBatch;
        currentBatch = _postageStamp.batches(batchId);
    }

    function sync() public override(IAutoSwarmMarket) {
        // 1/ check if current batch is about to expire ?
        // define condition for expiration !  1 week before expiration ?
        if (currentBatch.blockEnd <= block.number + (7 days / _SECONDS_PER_BLOCK)) {
            // 3.1/ If batch expires : Create new batch
            buyBatch();

            // 3.2/ Attach all stamps that have not expired to this new batch
            bytes32[] memory activeStampIds = getActiveStampIds();
        }

        // 2/ Check if new stamps have been defined ? (in current block ?)

        // 4.1/ if batch not expires
        // 4.2/ Only attach new stamp
    }

    function buyBatch() public override(IAutoSwarmMarket) onlyOwner returns (bytes32 batchId) {
        uint256 index = batchIds.length;
        bytes32 nonce = keccak256(abi.encode("Batch #index", index));

        batchId = keccak256(abi.encode(address(this), nonce));

        bzzToken.approve(address(_postageStamp), _INITIAL_TTL << _INITIAL_DEPTH);
        _postageStamp.createBatch(address(this), _INITIAL_TTL, _INITIAL_DEPTH, _BUCKET_DEPTH, nonce, false);

        setNewBatch(batchId);

        emit BuyBatch(batchId, index, _INITIAL_DEPTH, _INITIAL_TTL);
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
