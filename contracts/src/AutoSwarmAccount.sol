// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {ERC6551Registry} from "@erc6551/ERC6551Registry.sol";
import {SimpleERC6551Account} from "@erc6551/examples/simple/SimpleERC6551Account.sol";

import {IPostageStampLegacy} from "./interfaces/IPostageStampLegacy.sol";
import {IAutoSwarmAccount} from "./interfaces/IAutoSwarmAccount.sol";
import {Stamp, IAutoSwarmMarket} from "./interfaces/IAutoSwarmMarket.sol";
import {console} from "forge-std/console.sol";

/**
 * @title AutoSwarmAccount
 * @dev Contract for managing AutoSwarm accounts
 */
contract AutoSwarmAccount is IAutoSwarmAccount, SimpleERC6551Account {
    bytes32 public metadataHash;
    bytes32 public contentHash;

    // Stamp mapping
    mapping(uint256 => bytes32[2]) public stamp;

    IAutoSwarmMarket public autoSwarmMarket;
    bytes32 internal _nonce;

    /**
     * @dev Modifier to check if the contract has been initialized
     */
    modifier initialized() {
        require(_nonce != 0x0, "Not initialized");
        _;
    }

    /**
     * @dev Checks if the sender is the owner of the contract
     * @return ok True if the sender is the owner, false otherwise
     */
    function isOwner() external view returns (bool ok) {
        // Log the tx.origin, msg.sender and this contract address
        // console.log(tx.origin, "AutoSwarmAccount tx.origin");
        // console.log(msg.sender, "AutoSwarmAccount msg.sender");
        // console.log(address(this), "AutoSwarmAccount this");

        // Check if the sender is the owner of the contract
        ok = owner() == msg.sender;

        // Log the result of the check
        // console.log("AutoSwarmAccount isOwner", ok);
    }

    /**
     * @dev Initializes the contract with the AutoSwarmMarket contract address
     * @param autoSwarmMarket_ Address of the AutoSwarmMarket contract
     */
    function initialize(address autoSwarmMarket_) external override(IAutoSwarmAccount) {
        // Check if the contract has already been initialized
        require(_nonce == 0x0, "Already initialized");
        // Generate a new nonce for the contract
        _newNonce();

        // Set the address of the AutoSwarmMarket contract
        autoSwarmMarket = IAutoSwarmMarket(payable(autoSwarmMarket_));
    }

    /**
     * @dev Buys a year stamp from the AutoSwarmMarket contract
     * @param year The year for which the stamp is being bought
     * @param hash The hash of the file for which the stamp is being bought
     * @param size The size of the file for which the stamp is being bought
     * @param n The index of the stamp for the given year
     * @return stampId The ID of the stamp that was bought
     */
    function buyYearStamp(uint256 year, bytes32 hash, uint256 size, uint8 n)
        public
        override(IAutoSwarmAccount)
        returns (bytes32 stampId)
    {
        // Log the address of the autoSwarmMarket contract
        console.log(address(autoSwarmMarket), "buyYearStamp autoSwarmMarket");
        // Log the address of this contract
        console.log(address(this), "buyYearStamp this");

        // Approve the transfer of tokens to the autoSwarmMarket contract
        IERC20(autoSwarmMarket.bzzToken()).approve(address(autoSwarmMarket), autoSwarmMarket.getStampPrice(year, size));

        // Buy the stamp from the autoSwarmMarket contract
        stampId = autoSwarmMarket.buyStamp(year, hash, size, n);

        // Store the stamp ID in the mapping
        stamp[year][n] = stampId;
    }

    /**
     * @dev Withdraws tokens from the contract
     * @param token The address of the token to withdraw
     */
    function withdraw(address token) external {
        // Check if the sender is authorized to withdraw tokens
        require(_isValidSigner(msg.sender), "Not authorized");

        if (token == address(0)) {
            // If the token is ETH, transfer the balance to the sender
            (bool success,) = msg.sender.call{value: address(this).balance}("");
            require(success, "Withdraw failed!");
        } else {
            // If the token is not ETH, transfer the balance of the token to the sender
            IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
        }
    }

    /**
     * @dev Generates a new nonce for the contract
     * @return The new nonce
     */
    function _newNonce() internal returns (bytes32) {
        return _nonce = keccak256(abi.encode(address(this), _nonce));
    }
}
