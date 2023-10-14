// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {PostageStamp} from "storage-incentives/PostageStamp.sol";

import {Stamp, Batch, IAutoSwarmMarket} from "./interfaces/IAutoSwarmMarket.sol";
import {IPostageStampLegacy} from "./interfaces/IPostageStampLegacy.sol";

import {console} from "forge-std/console.sol";

/**
 * @title AutoSwarmMarket
 * @dev Implements the AutoSwarmMarket contract
 */
contract AutoSwarmMarket is IAutoSwarmMarket, Ownable {
    // Stamp mapping
    mapping(bytes32 => Stamp) public stamp;

    // Batch mapping
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

    /**
     * @dev Constructor function
     * @param postageStamp_ Address of the PostageStamp contract
     */
    constructor(address postageStamp_) {
        _setPostage(postageStamp_);
    }

    /**
     * @dev Sets the current year
     * @param year The year to set as current year
     */
    function setCurrentYear(uint256 year) external override(IAutoSwarmMarket) onlyOwner {
        currentYear = year;
    }

    /**
     * @dev Sets the PostageStamp contract address
     * @param postageStamp_ Address of the PostageStamp contract
     */
    function setPostage(address postageStamp_) external override(IAutoSwarmMarket) onlyOwner {
        _setPostage(postageStamp_);
    }

    /**
     * @dev Buys a batch for the given year
     * @param year The year to buy a batch for
     * @return batchId The ID of the bought batch
     */
    function buyBatch(uint256 year) external override(IAutoSwarmMarket) onlyOwner returns (bytes32 batchId) {
        // Check if batch already exists
        require(!existsBatch(year), "Batch already exists");
        // Check if year is the next year
        require(year == nextYear++, "Buy next year first");

        // Generate nonce for batch
        bytes32 nonce = keccak256(abi.encode("Batch of year", year));

        // Approve BZZ token for PostageStamp contract
        IERC20(bzzToken).approve(address(postageStamp), INITIAL_TTL << INITIAL_DEPTH);
        // Create batch using PostageStamp contract
        postageStamp.createBatch(address(this), INITIAL_TTL, INITIAL_DEPTH, BUCKET_DEPTH, nonce, false);

        // Generate batch ID
        batch[year].batchId = batchId = keccak256(abi.encode(address(this), nonce));

        // Emit BuyBatch event
        emit BuyBatch(batchId, year, INITIAL_DEPTH, INITIAL_TTL);
    }

    /**
     * @dev Extends the batch for the given year by increasing its depth
     * @param year The year to extend the batch for
     * @param deltaDepth The amount to increase the depth by
     */
    function extendsBatch(uint256 year, uint8 deltaDepth) external override(IAutoSwarmMarket) onlyOwner {
        // Get the remaining time-to-live (TTL) of the batch for the given year
        uint256 ttl = getBatchTtl(year);
        // Ensure that the batch is valid (i.e., the TTL is greater than zero)
        require(ttl > 0, "Batch not valid");

        // Dilute the batch for the given year by increasing its depth
        _diluteBatch(year, deltaDepth);

        // Calculate the new TTL for the batch after dilution and top-up
        uint256 mul = 1 << deltaDepth;
        uint256 newTtl = (ttl * (mul - 1)) / mul;

        // Top up the batch for the given year with the new TTL
        _topUpBatch(year, newTtl);

        // Ensure that the TTL of the batch is unchanged after dilution and top-up
        assert(getBatchTtl(year) == ttl);

        // Emit an event to indicate that the batch for the given year has been updated
        emit UpdateBatch(year, getBatchDepth(year), ttl);
    }

    /**
     * @dev Calculates the price of a stamp for the given year and size
     * @param year The year to calculate the stamp price for
     * @param size The size of the stamp
     * @return bzz The price of the stamp in BZZ tokens
     */
    function getStampPrice(uint256 year, uint256 size) public view override(IAutoSwarmMarket) returns (uint256 bzz) {
        // Get the remaining time-to-live (TTL) of the batch for the given year
        uint256 ttl = getBatchTtl(year);
        // Ensure that the batch year is valid (i.e., the TTL is greater than zero)
        require(ttl > 0, "Batch Year not valid");

        // Set the price of the stamp to 1 (for now)
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

    /**
     * @dev Buys a stamp for the given year with the given hash, size and quantity
     * @param year The year to buy the stamp for
     * @param hash The hash of the stamp
     * @param size The size of the stamp
     * @param n The quantity of the stamp
     * @return stampId The ID of the bought stamp
     */
    function buyStamp(uint256 year, bytes32 hash, uint256 size, uint8 n)
        external
        override(IAutoSwarmMarket)
        returns (bytes32 stampId)
    {
        // Get the ID of the previous stamp for the given year with the given hash and size
        bytes32 previousStampId = getStampId(year - 1, hash, size);
        // Ensure that the year is the current year or the previous stamp exists
        require(year == currentYear || previousStampId != bytes32(0));

        // Get the ID of the stamp for the given year with the given hash and size
        stampId = getStampId(year, hash, size);
        // Ensure that the stamp does not already exist
        require(stamp[stampId].stampId == bytes32(0), "Stamp already exists");

        // Calculate the new size of the batch for the given year after adding the size of the stamp
        uint256 newSize = batch[year].size + size;
        // Ensure that the new size of the batch does not exceed the size limit
        require(newSize * RATIO < getBatchSizeLimit(year), "No more space");

        // Calculate the price of the stamp in BZZ tokens
        uint256 bzz = getStampPrice(year, size);

        // Get the ID of the batch for the given year
        bytes32 batchId = batch[year].batchId;
        // Create a new stamp with the given ID, batch ID, year, size, hash, block number and price
        stamp[stampId] = Stamp(stampId, batchId, year, size, hash, block.number, bzz);

        // console.log("bzz:", bzz);
        // console.log("msg.sender:", msg.sender);
        // Transfer the BZZ tokens from the buyer to the contract
        require(IERC20(bzzToken).transferFrom(msg.sender, address(this), bzz), "Transfer failed");

        // Emit an event to indicate that the stamp has been bought
        emit BuyStamp(stampId, batchId, year, size, hash, block.number, bzz);

        // Return the ID of the bought stamp
        return stampId;
    }

    /**
     * @dev Returns the stamp with the given ID
     * @param stampId The ID of the stamp to return
     * @return stamp The stamp with the given ID
     */
    function getStamp(bytes32 stampId) public view returns (Stamp memory) {
        return stamp[stampId];
    }

    /**
     * @dev Returns the batch for the given year
     * @param year The year to return the batch for
     * @return batch The batch for the given year
     */
    function getBatch(uint256 year) public view returns (Batch memory) {
        return batch[year];
    }

    /**
     * @dev Checks if a batch exists for the given year
     * @param year The year to check for the existence of a batch
     * @return bool True if a batch exists for the given year, false otherwise
     */
    function existsBatch(uint256 year) public view returns (bool) {
        return batch[year].batchId != bytes32(0);
    }

    /**
     * @dev Returns the ID of the stamp for the given year, hash and size
     * @param year The year of the stamp
     * @param hash The hash of the stamp
     * @param size The size of the stamp
     * @return bytes32 The ID of the stamp for the given year, hash and size
     */
    function getStampId(uint256 year, bytes32 hash, uint256 size)
        public
        pure
        override(IAutoSwarmMarket)
        returns (bytes32)
    {
        return keccak256(abi.encode(year, hash, size));
    }

    /**
     * @dev Withdraws the specified token from the contract
     * @param token The address of the token to withdraw
     */
    function withdraw(address token) external override(IAutoSwarmMarket) onlyOwner {
        if (token == address(0)) {
            // Withdraw Ether from the contract
            (bool success,) = msg.sender.call{value: address(this).balance}("");
            require(success, "Withdraw failed!");
        } else {
            // Withdraw ERC20 tokens from the contract
            IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
        }
    }

    /**
     * @dev Tops up the batch for the given year with the given TTL
     * @param year The year to top up the batch for
     * @param ttl The TTL to top up the batch with
     */
    function topUpBatch(uint256 year, uint256 ttl) external override(IAutoSwarmMarket) onlyOwner {
        // Top up the batch for the given year with the given TTL
        _topUpBatch(year, ttl);

        // Emit an event to indicate that the batch for the given year has been updated
        emit UpdateBatch(year, getBatchDepth(year), ttl);
    }

    /**
     * @dev Dilutes the batch for the given year by increasing its depth
     * @param year The year to dilute the batch for
     * @param deltaDepth The amount to increase the depth by
     */
    function diluteBatch(uint256 year, uint8 deltaDepth) external override(IAutoSwarmMarket) onlyOwner {
        // Dilute the batch for the given year by increasing its depth
        _diluteBatch(year, deltaDepth);

        // Emit an event to indicate that the batch for the given year has been updated
        emit UpdateBatch(year, getBatchDepth(year) + deltaDepth, getBatchTtl(year));
    }

    /**
     * @dev Returns the size limit of the batch for the given year
     * @param year The year to return the size limit for
     * @return The size limit of the batch for the given year
     */
    function getBatchSizeLimit(uint256 year) public view override(IAutoSwarmMarket) returns (uint256) {
        return (BUCKET_SIZE << getBatchDepth(year)) / RATIO;
    }

    /**
     * @dev Returns the depth of the batch for the given year
     * @param year The year to return the depth for
     * @return The depth of the batch for the given year
     */
    function getBatchDepth(uint256 year) public view override(IAutoSwarmMarket) returns (uint8) {
        return postageStamp.batchDepth(batch[year].batchId);
    }

    /**
     * @dev Returns the remaining time-to-live (TTL) of the batch for the given year
     * @param year The year to return the TTL for
     * @return The remaining time-to-live (TTL) of the batch for the given year
     */
    function getBatchTtl(uint256 year) public view override(IAutoSwarmMarket) returns (uint256) {
        return postageStamp.remainingBalance(batch[year].batchId);
    }

    /**
     * @dev Tops up the batch for the given year with the given TTL
     * @param year The year to top up the batch for
     * @param ttl The TTL to top up the batch with
     */
    function _topUpBatch(uint256 year, uint256 ttl) internal {
        // Ensure that the batch for the given year is valid (i.e., the TTL is greater than zero)
        require(getBatchTtl(year) > 0, "Batch not valid");

        // Approve the transfer of BZZ tokens to the postage stamp contract
        IERC20(bzzToken).approve(address(postageStamp), ttl << getBatchDepth(year));
        // Top up the batch for the given year with the given TTL
        postageStamp.topUp(batch[year].batchId, ttl);
    }

    /**
     * @dev Dilutes the batch for the given year by increasing its depth
     * @param year The year to dilute the batch for
     * @param deltaDepth The amount to increase the depth by
     */
    function _diluteBatch(uint256 year, uint8 deltaDepth) internal {
        // Ensure that the batch for the given year is valid (i.e., the TTL is greater than zero)
        require(getBatchTtl(year) > 0, "Batch not valid");

        // Increase the depth of the batch for the given year by the given amount
        postageStamp.increaseDepth(batch[year].batchId, getBatchDepth(year) + deltaDepth);
    }

    /**
     * @dev Sets the postage stamp contract and BZZ token address
     * @param postageStamp_ The address of the postage stamp contract
     */
    function _setPostage(address postageStamp_) internal {
        // Set the postage stamp contract
        postageStamp = PostageStamp(payable(postageStamp_));
        // Set the BZZ token address
        bzzToken = postageStamp.bzzToken();
    }
}
