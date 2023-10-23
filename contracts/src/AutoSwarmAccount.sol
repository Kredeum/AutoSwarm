// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {ERC6551Registry} from "@erc6551/ERC6551Registry.sol";
import {SimpleERC6551Account} from "@erc6551/examples/simple/SimpleERC6551Account.sol";

import {IPostageStampLegacy} from "./interfaces/IPostageStampLegacy.sol";
import {IAutoSwarmAccount} from "./interfaces/IAutoSwarmAccount.sol";
import {Stamp, IAutoSwarmMarket} from "./interfaces/IAutoSwarmMarket.sol";
import {console} from "forge-std/console.sol";

contract AutoSwarmAccount is IAutoSwarmAccount, SimpleERC6551Account {
    bytes32 public metadataHash;
    bytes32 public contentHash;

    mapping(uint256 => bytes32[2]) public stamp;

    IAutoSwarmMarket public autoSwarmMarket;
    IERC20 public bzzToken;
    bytes32 internal _nonce;

    modifier initialized() {
        require(_nonce != 0x0, "Not initialized");
        _;
    }

    function isOwner() external view returns (bool ok) {
        ok = owner() == msg.sender;
    }

    function initialize(address autoSwarmMarket_) external override(IAutoSwarmAccount) {
        require(_nonce == 0x0, "Already initialized");

        _newNonce();

        autoSwarmMarket = IAutoSwarmMarket(payable(autoSwarmMarket_));
        bzzToken = IERC20(autoSwarmMarket.bzzToken());
    }

    function buyYearStamp(uint256 year, bytes32 hash, uint256 size, uint8 n)
        public
        override(IAutoSwarmAccount)
        returns (bytes32 stampId)
    {
        bzzToken.approve(address(autoSwarmMarket), autoSwarmMarket.getStampPrice(year, size));

        stampId = autoSwarmMarket.buyStamp(year, hash, size, n);

        stamp[year][n] = stampId;
    }

    function _newNonce() internal returns (bytes32) {
        return _nonce = keccak256(abi.encode(address(this), _nonce));
    }
}
