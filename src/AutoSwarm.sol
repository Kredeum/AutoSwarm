// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {PostageStamp} from "lib/storage-incentives/src/PostageStamp.sol";
import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";

// import {console} from "forge-std/Test.sol";

contract AutoSwarm {
    PostageStamp internal _postageStamp;
    IERC20 internal _bzzToken;
    uint256 internal _salt = uint256(keccak256("AutoSwarm smartcontrat"));

    constructor(address postageStamp_) {
        _postageStamp = PostageStamp(postageStamp_);
        _bzzToken = IERC20(_postageStamp.bzzToken());
    }

    function stampsBuy(uint256 ttl, uint8 depth) public returns (bytes32 batchId) {
        bytes32 nonce = keccak256(abi.encode(msg.sender, _salt++));
        uint8 minDepth = _postageStamp.minimumBucketDepth();

        _bzzToken.approve(address(_postageStamp), ttl << depth);
        _postageStamp.createBatch(msg.sender, ttl, depth, minDepth, nonce, false);

        batchId = keccak256(abi.encode(address(this), nonce));
    }

    function stampsTopUp(bytes32 batchId, uint256 ttl) public {
        // (, uint8 depth,,) = _postageStamp.batches(batchId); // v0.5
        (, uint8 depth,,,,) = _postageStamp.batches(batchId);

        _bzzToken.approve(address(_postageStamp), ttl << depth);
        _postageStamp.topUp(batchId, ttl);
    }
}
