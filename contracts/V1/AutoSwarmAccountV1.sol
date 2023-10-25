// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {ERC6551Registry} from "@erc6551/ERC6551Registry.sol";
import {SimpleERC6551Account} from "@erc6551/examples/simple/SimpleERC6551Account.sol";

import {IPostageStampLegacy} from "../interfaces/IPostageStampLegacy.sol";
import {IAutoSwarmAccountV1} from "../interfaces/IAutoSwarmAccountV1.sol";
import {IAutoSwarmMarketV1} from "../interfaces/IAutoSwarmMarketV1.sol";

contract AutoSwarmAccountV1 is IAutoSwarmAccountV1, SimpleERC6551Account {
    bytes32 public metadataHash;
    bytes32 public contentHash;

    // Stamp mapping
    mapping(uint256 => bytes32[2]) public stamp;

    IAutoSwarmMarketV1 public autoSwarmMarket;
    bytes32 internal _nonce;

    modifier initialized() {
        require(_nonce != 0x0, "Not initialized");
        _;
    }

    function initialize(address autoSwarmMarket_) external override(IAutoSwarmAccountV1) {
        require(_nonce == 0x0, "Already initialized");
        _newNonce();

        autoSwarmMarket = IAutoSwarmMarketV1(payable(autoSwarmMarket_));
    }

    function buyYearStamp(uint256 year, bytes32 hash, uint256 size, uint8 tp)
        public
        override(IAutoSwarmAccountV1)
        returns (bytes32 stampId)
    {
        stampId = autoSwarmMarket.buyStamp(year, hash, size, tp);
        stamp[year][tp] = stampId;
    }

    function withdraw(address token) external override(IAutoSwarmAccountV1) {
        require(_isValidSigner(msg.sender), "Not authorized");

        if (token == address(0)) {
            (bool success,) = msg.sender.call{value: address(this).balance}("");
            require(success, "Withdraw failed!");
        } else {
            IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
        }
    }

    function _newNonce() internal returns (bytes32) {
        return _nonce = keccak256(abi.encode(address(this), _nonce));
    }
}
