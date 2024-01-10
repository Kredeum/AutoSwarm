// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IPostageStamp} from "./interfaces/IPostageStamp.sol";
import {IAutoSwarmMarket} from "./interfaces/IAutoSwarmMarket.sol";

// import {console} from "forge-std/console.sol";

contract AutoSwarmMarket is Ownable, IAutoSwarmMarket {
    bytes32[] public batchIds;
    bytes32 public currentBatchId;
    address public currentNodeOwner;
    uint256 public currentBatchFilling;

    bytes32[] public stampIds;

    mapping(bytes32 => bytes32) public stampToBatchId;
    mapping(bytes32 => Stamp) public stamps;

    // stamp UNIT size is 1 Mb
    uint256 public constant STAMP_UNIT_SIZE = 1024 ** 2; // 1 Mb

    // mimic PostageStamp batch calculation, for stamp calculation
    uint256 public stampUnitPrice;
    uint256 public stampsLastOutPayment;
    uint256 public stampsLastBlockUpdate;

    address public postageStamp;
    address public bzzToken;

    uint256 internal constant _EXPIRATION_TTL = 7 days;
    uint256 internal constant _BATCH_TTL = 30 days;
    uint8 internal constant _BATCH_DEPTH = 23;

    uint8 internal constant _BUCKET_DEPTH = 16;
    uint256 internal constant _SECONDS_PER_BLOCK = 5;
    uint256 internal constant _SECOND_PER_YEAR = 365 * 24 * 3600;

    constructor(address postageStamp_, address swarmNodeOwner_) {
        if (postageStamp_ == address(0)) revert PostageStampNull();
        if (swarmNodeOwner_ == address(0)) revert NodeOwnerNull();

        postageStamp = postageStamp_;
        currentNodeOwner = swarmNodeOwner_;

        bzzToken = IPostageStamp(postageStamp).bzzToken();

        setStampUnitPrice(2e8);
    }

    function extendsBatch(bytes32 batchId, uint8 deltaDepth) external override(IAutoSwarmMarket) onlyOwner {
        uint256 ttl = IPostageStamp(postageStamp).remainingBalance(batchId);
        if (ttl == 0) revert InvalidBatch();

        uint8 newDepth = IPostageStamp(postageStamp).batchDepth(batchId) + deltaDepth;

        _diluteBatch(batchId, newDepth);
        assert(IPostageStamp(postageStamp).batchDepth(batchId) == newDepth);

        uint256 mul = 1 << deltaDepth;
        uint256 newTtl = (ttl * (mul - 1)) / mul;

        emit ExtendsBatch(batchId, newDepth, newTtl);
        _topUpBatch(batchId, newTtl);

        assert(IPostageStamp(postageStamp).remainingBalance(batchId) == ttl);
    }

    function updateStamp(bytes32 stampId, bytes32 swarmHash, uint256 swarmSize)
        public
        override(IAutoSwarmMarket)
        onlyOwner
    {
        if (swarmHash == bytes32(0)) revert SwarmHashNull();
        if (swarmSize == 0) revert SwarmSizeZero();

        Stamp storage stamp = stamps[stampId];

        stamp.swarmHash = swarmHash;
        stamp.swarmSize = swarmSize;

        emit UpdateStamp(stampId, swarmHash, swarmSize);
    }

    function createStamp(bytes32 swarmHash, uint256 swarmSize, uint256 bzzAmount)
        public
        override(IAutoSwarmMarket)
        returns (bytes32 stampId)
    {
        if (swarmHash == bytes32(0)) revert SwarmHashNull();
        if (swarmSize == 0) revert SwarmSizeZero();

        Stamp memory stamp = Stamp({
            owner: msg.sender,
            swarmHash: swarmHash,
            swarmSize: swarmSize,
            normalisedBalance: stampsTotalOutPayment()
        });
        stampId = keccak256(abi.encode(msg.sender, swarmHash, block.number));

        stamps[stampId] = stamp;
        stampIds.push(stampId);

        if (bzzAmount > 0) _topUpStamp(stampId, bzzAmount);

        emit CreateStamp(stampId, swarmHash, swarmSize, bzzAmount);
    }

    function topUpStamp(bytes32 stampId, uint256 bzzAmount) public override(IAutoSwarmMarket) {
        _topUpStamp(stampId, bzzAmount);
    }

    function setStampUnitPrice(uint256 price) public override(IAutoSwarmMarket) onlyOwner {
        stampsLastOutPayment = stampsTotalOutPayment();
        stampsLastBlockUpdate = block.number;
        stampUnitPrice = price;

        emit SetStampUnitPrice(stampUnitPrice);
    }

    function setStampsSize(bytes32[] memory stampIdsToSize, uint256 size) public override(IAutoSwarmMarket) onlyOwner {
        uint256 len = stampIdsToSize.length;
        for (uint256 index; index < len; index++) {
            bytes32 stampId = stampIdsToSize[index];
            Stamp storage stamp = stamps[stampId];
            stamp.swarmSize = size;

            emit UpdateStamp(stampId, stamp.swarmHash, size);
        }
    }

    function attachStamps(bytes32[] memory stampIdsToAttach, bytes32 batchId)
        public
        override(IAutoSwarmMarket)
        onlyOwner
    {
        if (currentBatchId == bytes32(0)) revert BatchNull();
        if (batchId != currentBatchId) revert NotCurrentBatch();

        uint256 len = stampIdsToAttach.length;

        for (uint256 index; index < len; index++) {
            bytes32 stampId = stampIdsToAttach[index];
            stampToBatchId[stampId] = currentBatchId;

            emit AttachStamp(stampId, currentBatchId);
        }
    }

    function sync() public override(IAutoSwarmMarket) returns (bytes32) {
        if (newBatchNeeded()) _newBatch(getBatchPrice());

        return currentBatchId;
    }

    function setBatch(bytes32 batchId, uint256 batchFilling) public override(IAutoSwarmMarket) onlyOwner {
        _setBatch(batchId, batchFilling);
    }

    function newBatchNeeded() public view override(IAutoSwarmMarket) returns (bool) {
        if (currentBatchId == bytes32(0)) return true;

        // 1/ Check if current batch is about to expire ? i.e. 1 week before expiration
        uint256 remainingBalance = IPostageStamp(postageStamp).remainingBalance(currentBatchId);
        uint256 neededBalance = IPostageStamp(postageStamp).lastPrice() * (_EXPIRATION_TTL / _SECONDS_PER_BLOCK);
        bool aboutToExpire = remainingBalance <= neededBalance;

        // 2/ Check if batch is about to be full ? i.e. 1/2 of batch filled for depth 23
        // if dilute is used, use real batch depth instead od _BATCH_DEPTH
        bool aboutToSemiFull = currentBatchFilling * 2 >= (1 << _BATCH_DEPTH);

        // 3/ If batch expires or semi full
        // another solution for semi full action would be to extends batch...
        return aboutToExpire || aboutToSemiFull;
    }

    function getBatchPrice() public view override(IAutoSwarmMarket) returns (uint256) {
        return (IPostageStamp(postageStamp).lastPrice() << _BATCH_DEPTH) * (_BATCH_TTL / _SECONDS_PER_BLOCK);
    }

    function getStampUnitPriceOneYear() public view override(IAutoSwarmMarket) returns (uint256) {
        return stampUnitPrice * (_SECOND_PER_YEAR / _SECONDS_PER_BLOCK);
    }

    function getStampPriceOneYear(uint256 size) public view override(IAutoSwarmMarket) returns (uint256) {
        return getStampUnitPriceOneYear() * getMbSize(size);
    }

    function isStampActive(bytes32 stampId) public view override(IAutoSwarmMarket) returns (bool) {
        return getStampRemainingBalance(stampId) > 0;
    }

    function getStampsCount() public view override(IAutoSwarmMarket) returns (uint256) {
        return stampIds.length;
    }

    function getStampIds(uint256 skip, uint256 limit)
        public
        view
        override(IAutoSwarmMarket)
        returns (bytes32[] memory stampIdsSubset, bytes32[] memory batchIdsSubset)
    {
        if ((skip >= stampIds.length) || (limit == 0)) return (stampIdsSubset, batchIdsSubset);
        if (skip + limit > stampIds.length) limit = stampIds.length - skip;

        stampIdsSubset = new bytes32[](limit);
        batchIdsSubset = new bytes32[](limit);
        for (uint256 index = 0; index < limit; index++) {
            bytes32 stampId = stampIds[skip + index];
            stampIdsSubset[index] = stampId;
            batchIdsSubset[index] = stampToBatchId[stampId];
        }
    }

    function getStampIdsToAttach(uint256 skip, uint256 limit)
        public
        view
        override(IAutoSwarmMarket)
        returns (bytes32[] memory stampIdsToAttach)
    {
        if ((skip >= stampIds.length) || (limit == 0)) return stampIdsToAttach;
        if (skip + limit > stampIds.length) limit = stampIds.length - skip;

        uint256 indexCount;
        bytes32[] memory stampIdsTmp = new bytes32[](limit);

        for (uint256 index = skip; index < (skip + limit); index++) {
            bytes32 stampId = stampIds[index];
            Stamp memory stamp = stamps[stampId];

            // test Stamp is active AND not already attached to current batch
            bool stampIsActive = stamp.normalisedBalance >= stampsTotalOutPayment();
            bool stampIsNotAttachedToCurrentBatch = stampToBatchId[stampId] != currentBatchId;

            if (stampIsActive && stampIsNotAttachedToCurrentBatch) {
                stampIdsTmp[indexCount++] = stampId;
            }
        }

        if (indexCount == 0) return stampIdsToAttach;
        stampIdsToAttach = new bytes32[](indexCount);

        for (uint256 index = 0; index < indexCount; index++) {
            stampIdsToAttach[index] = stampIdsTmp[index];
        }
    }

    function stampsTotalOutPayment() public view override(IAutoSwarmMarket) returns (uint256) {
        uint256 blocks = block.number - stampsLastBlockUpdate;
        uint256 stampsOutPaymentIncrease = stampUnitPrice * blocks;
        return stampsLastOutPayment + stampsOutPaymentIncrease;
    }

    function getStampRemainingBalance(bytes32 stampId) public view override(IAutoSwarmMarket) returns (uint256) {
        Stamp memory stamp = stamps[stampId];
        if (stamp.swarmHash == bytes32(0)) return 0;

        return _subPos(stamp.normalisedBalance, stampsTotalOutPayment());
    }

    function getMbSize(uint256 size) public pure override(IAutoSwarmMarket) returns (uint256) {
        return _divUp(size, STAMP_UNIT_SIZE);
    }

    function _setBatch(bytes32 batchId, uint256 batchFilling) internal {
        if (batchId == bytes32(0)) revert BatchNull();
        if (batchId == currentBatchId) revert BatchExists();

        address batchOwner = IPostageStamp(postageStamp).batchOwner(batchId);
        if (batchOwner == address(0)) revert InvalidBatch();

        currentBatchId = batchId;
        currentNodeOwner = batchOwner;
        currentBatchFilling = batchFilling;
        batchIds.push(batchId);

        emit SetBatch(batchId, batchFilling);
    }

    function _topUpStamp(bytes32 stampId, uint256 bzzAmount) internal {
        Stamp storage stamp = stamps[stampId];
        if (stamp.swarmHash == bytes32(0)) revert StampNull();

        uint256 swarmSize = stamp.swarmSize;
        uint256 normalisedBalance = stamp.normalisedBalance;
        uint256 swarmMbSize = getMbSize(swarmSize);
        if (swarmMbSize == 0) revert SwarmMbSizeZero();

        currentBatchFilling += swarmSize;

        uint256 normalisedBzzAmount = bzzAmount / swarmMbSize;
        uint256 bzzAmountToTranfer = normalisedBzzAmount * swarmMbSize;

        stamp.normalisedBalance = normalisedBalance + normalisedBzzAmount;

        emit TopUpStamp(stampId, bzzAmount);

        SafeERC20.safeTransferFrom(IERC20(bzzToken), msg.sender, address(this), bzzAmountToTranfer);
    }

    function _newBatch(uint256 bzzAmount) internal returns (bytes32 batchId) {
        if (currentNodeOwner == address(0)) revert NodeOwnerNull();
        if (bzzAmount == 0) revert AmountZero();

        // slither-disable-next-line reentrancy-no-eth
        SafeERC20.safeIncreaseAllowance(IERC20(bzzToken), address(postageStamp), bzzAmount);
        batchId = IPostageStamp(postageStamp).createBatch(
            currentNodeOwner,
            bzzAmount >> _BATCH_DEPTH,
            _BATCH_DEPTH,
            _BUCKET_DEPTH,
            keccak256(abi.encode("Batch #index", batchIds.length)),
            false
        );

        _setBatch(batchId, 0);
    }

    function _diluteBatch(bytes32 batchId, uint8 depth) internal {
        IPostageStamp(postageStamp).increaseDepth(batchId, depth);
    }

    function _topUpBatch(bytes32 batchId, uint256 ttl) internal {
        SafeERC20.safeIncreaseAllowance(
            IERC20(bzzToken), address(postageStamp), ttl << IPostageStamp(postageStamp).batchDepth(batchId)
        );
        IPostageStamp(postageStamp).topUp(batchId, ttl);
    }

    // _divUp: ceiled integer div (instead of floored)
    // 0/100 = 0  1/100 = 1   100/100 = 1   101/100 = 2
    function _divUp(uint256 a, uint256 b) internal pure returns (uint256) {
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    // _subPos: substract with underflow protection
    // 0 - 1 = 0   3 - 1 = 2   10 - 12 = 0    23 - 5 = 18
    function _subPos(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a - b : 0;
    }
}
