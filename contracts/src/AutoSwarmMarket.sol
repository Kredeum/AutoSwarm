// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IAutoSwarmMarket, IPostageStamp, IERC20} from "./interfaces/IAutoSwarmMarket.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {console} from "forge-std/console.sol";

contract AutoSwarmMarket is Ownable {
    struct Stamp {
        address owner;
        bytes32 swarmHash;
        uint256 swarmSize;
        uint256 normalisedUnit;
    }

    event UpdateStampUnitPrice(uint256 indexed stampUnitPrice);

    bytes32[] public batchIds;
    IPostageStamp.Batch public previousBatch;
    IPostageStamp.Batch public currentBatch;

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

    constructor(address postageStamp_) {
        _postageStamp = IPostageStamp(payable(postageStamp_));
        bzzToken = IERC20(_postageStamp.bzzToken());
        stampBlockUpdate = block.number;
        setStampUnitPrice(2e8);
    }

    function sync() public {}

    function createStamp(bytes32 hash, uint256 size, uint256 bzzAmount) public returns (bytes32 stampId) {
        Stamp memory stamp =
            Stamp({owner: msg.sender, swarmHash: hash, swarmSize: size, normalisedUnit: _stampUnitPaid() + bzzAmount});
        stampId = keccak256(abi.encode(msg.sender, hash, size));

        stamps[stampId] = stamp;
        stampIds.push(stampId);

        _topUpStamp(stamps[stampId], bzzAmount);
    }

    function topUpStamp(bytes32 stampId, uint256 bzzAmount) public {
        _topUpStamp(stamps[stampId], bzzAmount);
    }

    function _topUpStamp(Stamp storage stamp, uint256 bzzAmount) internal {
        require(stamp.swarmSize > 0, "Bad Swarm size");

        uint256 bzzAmountUnit = bzzAmount / getMbSize(stamp.swarmSize);

        uint256 normalisedUnit = stamp.normalisedUnit;
        normalisedUnit += bzzAmountUnit;
        stamp.normalisedUnit = normalisedUnit;

        uint256 bzzAmountTotranfer = bzzAmountUnit * getMbSize(stamp.swarmSize);

        // bzzAmountTotranfer slightly less than bzzAmount due to div rounding
        assert(bzzAmountTotranfer == (bzzAmount - bzzAmount % getMbSize(stamp.swarmSize)));

        require(bzzToken.transferFrom(msg.sender, address(this), bzzAmountTotranfer), "Transfer failed");

        sync();
    }

    function setStampUnitPrice(uint256 unitPrice) public onlyOwner {
        stampUnitPaid = _stampUnitPaid();
        stampUnitPrice = unitPrice;
        stampBlockUpdate = block.number;

        emit UpdateStampUnitPrice(stampUnitPrice);
    }

    function getStampUnitPriceOneYear() public view onlyOwner returns (uint256) {
        return stampUnitPrice * _BLOCKS_PER_YEAR;
    }

    function getStampPriceOneYear(uint256 size) public view returns (uint256) {
        return stampUnitPrice * _BLOCKS_PER_YEAR * getMbSize(size);
    }

    function getMbSize(uint256 size) public pure returns (uint256) {
        return _ceilDiv(size, STAMP_UNIT_SIZE);
    }

    function getStampRemainingBzz(bytes32 stampId) public view returns (uint256) {
        Stamp memory stamp = stamps[stampId];
        require(stamp.owner != address(0), "Stamp not exists");

        return _subPos(stamp.normalisedUnit, getMbSize(stamp.swarmSize) * _stampUnitPaid());
    }

    function isStampActive(bytes32 stampId) public view returns (bool) {
        return getStampRemainingBzz(stampId) > 0;
    }

    function isStampExists(bytes32 stampId) public view returns (bool) {
        return stamps[stampId].swarmSize > 0;
    }

    function getActiveStampIds() public view returns (uint256[] memory activeStampIds) {
        uint256 len = stampIds.length;

        for (uint256 index; index < len; index++) {
            bytes32 stampId = stampIds[index];

            if (isStampActive(stampId)) {
                // activeStampIds.push(stampId);
            }
        }
    }

    function setNewBatch(bytes32 batchId) internal {
        // previousBatch = currentBatch;
        // currentBatch = _postageStamp.batches(batchId);
    }

    // function sync() public  {
    // 1/ check if current batch is about to expire ?
    // define condition for expiration !  1 week before expiration ?
    // if (currentBatch.blockEnd <= block.number + (7 days / _SECONDS_PER_BLOCK)) {
    //     // 3.1/ If batch expires : Create new batch
    //     buyBatch();

    //     // 3.2/ Attach all stamps that have not expired to this new batch
    //     bytes32[] memory activeStampIds = getActiveStampIds();
    // }

    // 2/ Check if new stamps have been defined ? (in current block ?)

    // 4.1/ if batch not expires
    // 4.2/ Only attach new stamp
    // }

    function buyBatch() public onlyOwner returns (bytes32 batchId) {
        uint256 index = batchIds.length;
        bytes32 nonce = keccak256(abi.encode("Batch #index", index));

        batchId = keccak256(abi.encode(address(this), nonce));

        bzzToken.approve(address(_postageStamp), _INITIAL_TTL << _INITIAL_DEPTH);
        _postageStamp.createBatch(address(this), _INITIAL_TTL, _INITIAL_DEPTH, _BUCKET_DEPTH, nonce, false);

        setNewBatch(batchId);
    }

    function extendsBatch(bytes32 batchId, uint8 deltaDepth) external onlyOwner {
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

    function _stampUnitPaid() internal view returns (uint256) {
        uint256 blocks = block.number - stampBlockUpdate;
        uint256 stampUnitPaidIncrease = stampUnitPrice * blocks;
        return stampUnitPaid + stampUnitPaidIncrease;
    }

    function _diluteBatch(bytes32 batchId, uint8 depth) internal {
        _postageStamp.increaseDepth(batchId, depth);
    }

    function _topUpBatch(bytes32 batchId, uint256 ttl) internal {
        bzzToken.approve(address(_postageStamp), ttl << _postageStamp.batchDepth(batchId));
        _postageStamp.topUp(batchId, ttl);
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
