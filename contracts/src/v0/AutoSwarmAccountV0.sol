// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {PostageStamp} from "storage-incentives/PostageStamp.sol";
import {ERC6551Registry} from "@erc6551/ERC6551Registry.sol";
import {SimpleERC6551Account} from "@erc6551/examples/simple/SimpleERC6551Account.sol";

import {IAutoSwarmAccount} from "../interfaces/IAutoSwarmAccountV0.sol";
import {IPostageStampLegacy} from "../interfaces/IPostageStampLegacy.sol";

contract AutoSwarmAccountV0 is IAutoSwarmAccount, SimpleERC6551Account {
    PostageStamp public postageStamp;
    bytes32 internal _nonce;

    modifier initialized() {
        require(_nonce != 0x0, "Not initialized");
        _;
    }

    function initialize(address postageStamp_) external override(IAutoSwarmAccount) {
        require(_nonce == 0x0, "Already initialized");
        _newNonce();

        postageStamp = PostageStamp(payable(postageStamp_));
    }

    function stampsIncreaseDepth(bytes32 batchId, uint8 newDepth) external override(IAutoSwarmAccount) initialized {
        postageStamp.increaseDepth(batchId, newDepth);
    }

    function stampsBuy(uint256 ttl, uint8 depth) external override(IAutoSwarmAccount) initialized returns (bytes32) {
        bytes32 nonce = _newNonce();
        uint8 minDepth = postageStamp.minimumBucketDepth();
        IERC20 bzzToken = IERC20(postageStamp.bzzToken());

        bzzToken.approve(address(postageStamp), ttl << depth);
        postageStamp.createBatch(address(this), ttl, depth, minDepth, nonce, false);

        return keccak256(abi.encode(address(this), nonce));
    }

    function stampsTopUp(bytes32 batchId, uint256 ttl) external override(IAutoSwarmAccount) initialized {
        IERC20 bzzToken = IERC20(postageStamp.bzzToken());

        uint8 depth;
        if (block.chainid == 100) {
            (, depth,,) = IPostageStampLegacy(address(postageStamp)).batches(batchId);
        } else {
            (, depth,,,,) = postageStamp.batches(batchId);
        }

        bzzToken.approve(address(postageStamp), ttl << depth);
        postageStamp.topUp(batchId, ttl);
    }

    function withdraw(address token) external override(IAutoSwarmAccount) {
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
