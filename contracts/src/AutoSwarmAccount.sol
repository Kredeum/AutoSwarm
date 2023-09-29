// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {ERC6551Registry} from "erc6551/src/ERC6551Registry.sol";
import {PostageStamp} from "storage-incentives/PostageStamp.sol";

import {ERC6551Account} from "@autoswarm/src/ERC6551Account.sol";
// import {console} from "forge-std/console.sol";

interface IPostageStampLegacy {
    function batches(bytes32) external returns (address, uint8, bool, uint256);
}

contract AutoSwarmAccount is ERC6551Account {
    PostageStamp public postageStamp;
    bytes32 internal _nonce;

    modifier initialized() {
        require(_nonce != 0x0, "Not initialized");
        _;
    }

    function initialize(address postageStamp_) external {
        require(_nonce == 0x0, "Already initialized");
        _newNonce();

        postageStamp = PostageStamp(payable(postageStamp_));
    }

    function stampsBuy(uint256 ttl, uint8 depth) public initialized returns (bytes32) {
        bytes32 nonce = _newNonce();
        uint8 minDepth = postageStamp.minimumBucketDepth();
        IERC20 bzzToken = IERC20(postageStamp.bzzToken());

        bzzToken.approve(address(postageStamp), ttl << depth);
        postageStamp.createBatch(address(this), ttl, depth, minDepth, nonce, false);

        return keccak256(abi.encode(address(this), nonce));
    }

    function stampsTopUp(bytes32 batchId, uint256 ttl) public initialized {
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

    function stampsIncreaseDepth(bytes32 batchId, uint8 newDepth) external initialized {
        postageStamp.increaseDepth(batchId, newDepth);
    }

    function withdraw() external {
        (bool success,) = owner().call{value: address(this).balance}("");
        require(success, "Withdraw failed!");
    }

    function withdrawERC20(address token) public {
        IERC20(token).transfer(owner(), IERC20(token).balanceOf(address(this)));
    }

    function withdrawBzz() external {
        withdrawERC20(address(postageStamp.bzzToken()));
    }

    function _newNonce() public returns (bytes32) {
        return _nonce = keccak256(abi.encode(address(this), _nonce));
    }
}
