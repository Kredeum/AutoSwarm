// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IAutoSwarmMarket, IPostageStamp, IERC20} from "./interfaces/IAutoSwarmMarket.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// import {console} from "forge-std/console.sol";

contract AutoSwarmMarket is Ownable {
    struct Stamp {
        // immutable
        address owner;
        bytes32 bzzHash;
        uint256 swarmSize;
        // mutable
        bytes32 batchId;
        uint256 unitBalance;
    }

    bytes32[] public batchIds;
    bytes32 public currentBatchId;
    uint256 public currentBatchFilling;

    bytes32[] public stampIds;
    mapping(bytes32 => Stamp) public stamps;

    // stamp UNIT size is 1 Mb
    uint256 public constant STAMP_UNIT_SIZE = 1024 ** 2; // 1 Mo

    // mimic PostageStamp batch calculation, for stamp calculation
    uint256 public stampUnitPaid;
    uint256 public stampUnitPrice;
    uint256 public stampBlockUpdate;

    IPostageStamp internal _postageStamp;
    IERC20 public bzzToken;

    uint256 internal constant _EXPIRATION_TTL = 7 days;
    uint256 internal constant _INITIAL_TTL = 30 days;
    uint8 internal constant _INITIAL_DEPTH = 23;
    uint8 internal constant _BUCKET_DEPTH = 16;

    uint256 internal constant _SECONDS_PER_BLOCK = 5;
    uint256 internal constant _SECOND_PER_YEAR = 365 * 24 * 3600;
    uint256 internal constant _BLOCKS_PER_YEAR = _SECOND_PER_YEAR / _SECONDS_PER_BLOCK;

    event UpdateStampUnitPrice(uint256 indexed stampUnitPrice);

    constructor(address postageStamp_) {
        _postageStamp = IPostageStamp(payable(postageStamp_));
        bzzToken = IERC20(_postageStamp.bzzToken());
        stampBlockUpdate = block.number;
        setStampUnitPrice(2e8);
    }

    function extendsBatch(bytes32 batchId, uint8 deltaDepth) external {
        uint256 ttl = _postageStamp.remainingBalance(batchId);
        require(ttl > 0, "Batch not valid");

        uint8 newDepth = _postageStamp.batchDepth(batchId) + deltaDepth;

        _diluteBatch(batchId, newDepth);
        assert(_postageStamp.batchDepth(batchId) == newDepth);

        uint256 mul = 1 << deltaDepth;
        uint256 newTtl = (ttl * (mul - 1)) / mul;

        _topUpBatch(batchId, newTtl);
        assert(_postageStamp.remainingBalance(batchId) == ttl);
    }

    function createStamp(bytes32 hash, uint256 bzzAmount) public returns (bytes32 stampId) {
        require(hash != bytes32(0), "Bad Swarm Hash");

        Stamp memory stamp =
            Stamp({owner: msg.sender, bzzHash: hash, swarmSize: 1, batchId: "", unitBalance: currentStampUnitPaid()});
        stampId = keccak256(abi.encode(msg.sender, hash, block.number));

        stamps[stampId] = stamp;
        stampIds.push(stampId);

        if (bzzAmount > 0) _topUpStamp(stamps[stampId], bzzAmount);
    }

    function topUpStamp(bytes32 stampId, uint256 bzzAmount) public {
        _topUpStamp(stamps[stampId], bzzAmount);
    }

    function setStampUnitPrice(uint256 unitPrice) public {
        stampUnitPaid = currentStampUnitPaid();
        stampUnitPrice = unitPrice;
        stampBlockUpdate = block.number;

        emit UpdateStampUnitPrice(stampUnitPrice);
    }

    function setStampsSize(bytes32[] memory stampIdsToSize, uint256 size) public {
        uint256 len = stampIdsToSize.length;

        for (uint256 index; index < len; index++) {
            stamps[stampIdsToSize[index]].swarmSize = size;
        }
    }

    function setStampsAttached(bytes32[] memory stampIdsAttached, bytes32 batchId) public {
        uint256 len = stampIdsAttached.length;

        for (uint256 index; index < len; index++) {
            stamps[stampIdsAttached[index]].batchId = batchId;
        }
    }

    function sync() public {
        // 1/ Check if current batch is about to expire ? i.e. 1 week before expiration
        uint256 remainingBalance = _postageStamp.remainingBalance(currentBatchId);
        uint256 neededBalance = (_postageStamp.lastPrice() * 7 days) / _SECONDS_PER_BLOCK;
        bool aboutToExpire = remainingBalance <= neededBalance;

        // 2/ Check if batch is about to be full ? i.e. 1/2 of batch filled for depth 23
        // if dilute is used, use real batch depth instead od _INITIAL_DEPTH
        bool aboutToBeSemiFull = currentBatchFilling * 2 >= (1 << _INITIAL_DEPTH);

        // 3/ If batch expires or semi full: Create new batch
        // another solution for semi fulla ction would be to extends batch...
        if (aboutToExpire || aboutToBeSemiFull) newBatch();
    }

    function newBatch() public returns (bytes32 batchId) {
        uint256 index = batchIds.length;
        bytes32 nonce = keccak256(abi.encode("Batch #index", index));

        batchId = keccak256(abi.encode(address(this), nonce));
        currentBatchFilling = 0;
        currentBatchId = batchId;

        bzzToken.approve(address(_postageStamp), _INITIAL_TTL << _INITIAL_DEPTH);
        _postageStamp.createBatch(address(this), _INITIAL_TTL, _INITIAL_DEPTH, _BUCKET_DEPTH, nonce, false);

        batchIds.push(currentBatchId);
    }

    function getStampUnitPriceOneYear() public view returns (uint256) {
        return stampUnitPrice * _BLOCKS_PER_YEAR;
    }

    function getStampPriceOneYear(uint256 size) public view returns (uint256) {
        return getStampUnitPriceOneYear() * getMbSize(size);
    }

    function isStampActive(bytes32 stampId) public view returns (bool) {
        return _getStampBzzRemaining(stamps[stampId]) > 0;
    }

    function getStamp(bytes32 stampId) public view returns (Stamp memory) {
        bytes32[] memory stampIdsOne = new bytes32[](1);
        stampIdsOne[0] = stampId;
        return getStamps(stampIdsOne)[0];
    }

    function getStamps(bytes32[] memory stampIdsList) public view returns (Stamp[] memory stampsList) {
        uint256 len = stampIdsList.length;
        stampsList = new Stamp[](len);

        for (uint256 index; index < len; index++) {
            stampsList[index] = stamps[stampIdsList[index]];
        }
    }

    function getStampIdsToAttach(uint256 skip, uint256 limit) public view returns (bytes32[] memory stampIdsToAttach) {
        require(skip + limit <= stampIds.length, "Out of bounds");

        uint256 toAttachIndex;
        stampIdsToAttach = new bytes32[](limit);

        for (uint256 index = skip; index < (skip + limit); index++) {
            bytes32 stampId = stampIds[index];
            Stamp memory stamp = stamps[stampId];

            // test Stamp is active AND not already attached to current batch
            bool stampIsActive = stamp.unitBalance >= currentStampUnitPaid();
            bool stampIsNotAttachedToCurrentBatch = stamp.batchId != currentBatchId;

            if (stampIsActive && stampIsNotAttachedToCurrentBatch) stampIdsToAttach[toAttachIndex++] = stampId;
        }
    }

    function currentStampUnitPaid() public view returns (uint256) {
        uint256 blocks = block.number - stampBlockUpdate;
        uint256 stampUnitPaidIncrease = stampUnitPrice * blocks;
        return stampUnitPaid + stampUnitPaidIncrease;
    }

    function getMbSize(uint256 size) public pure returns (uint256) {
        return _ceilDiv(size, STAMP_UNIT_SIZE);
    }

    function _topUpStamp(Stamp storage stamp, uint256 bzzAmount) internal {
        require(stamp.swarmSize > 0, "Bad Swarm size");

        uint256 bzzAmountUnit = bzzAmount / getMbSize(stamp.swarmSize);

        currentBatchFilling += stamp.swarmSize;

        uint256 unitBalance = stamp.unitBalance;
        unitBalance += bzzAmountUnit;
        stamp.unitBalance = unitBalance;

        uint256 bzzAmountTotranfer = bzzAmountUnit * getMbSize(stamp.swarmSize);

        // bzzAmountTotranfer slightly less than bzzAmount due to div rounding
        assert(bzzAmountTotranfer == (bzzAmount - bzzAmount % getMbSize(stamp.swarmSize)));

        require(bzzToken.transferFrom(msg.sender, address(this), bzzAmountTotranfer), "Transfer failed");

        sync();
    }

    function _diluteBatch(bytes32 batchId, uint8 depth) internal {
        _postageStamp.increaseDepth(batchId, depth);
    }

    function _topUpBatch(bytes32 batchId, uint256 ttl) internal {
        bzzToken.approve(address(_postageStamp), ttl << _postageStamp.batchDepth(batchId));
        _postageStamp.topUp(batchId, ttl);
    }

    function _getStampBzzRemaining(Stamp storage stamp) internal view returns (uint256) {
        require(stamp.owner != address(0), "Stamp not exists");

        return _subPos(stamp.unitBalance, currentStampUnitPaid()) * getMbSize(stamp.swarmSize);
    }

    // _ceilDiv: ceiled integer div (instead of floored)
    // 0/100 = 0  1/100 = 1   100/100 = 1   101/100 = 2
    function _ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    // _subPos: substract with underflow protection
    // 0 - 1 = 0   3 - 1 = 2   10 - 12 = 0    23 - 5 = 18
    function _subPos(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a - b : 0;
    }
}
