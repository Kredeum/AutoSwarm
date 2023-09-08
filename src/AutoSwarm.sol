// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {PostageStamp} from "lib/storage-incentives/src/PostageStamp.sol";
import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";
import {SimpleERC6551Account} from "lib/erc6551/src/examples/simple/SimpleERC6551Account.sol";
import {ERC6551Registry} from "lib/erc6551/src/ERC6551Registry.sol";

// import {console} from "forge-std/Test.sol";

contract AutoSwarm {
    ERC6551Registry _registry;
    SimpleERC6551Account _implementation;
    PostageStamp internal _postageStamp;
    IERC20 internal _bzzToken;

    constructor(address registry_, address payable implementation_, address payable postageStamp_) {
        _registry = ERC6551Registry(registry_);
        _implementation = SimpleERC6551Account(implementation_);
        _postageStamp = PostageStamp(postageStamp_);
        _bzzToken = IERC20(_postageStamp.bzzToken());
    }

    function stampsBuy(uint256 ttl, uint8 depth, bytes32 nonce) public returns (bytes32) {
        uint8 minDepth = _postageStamp.minimumBucketDepth();

        _bzzToken.approve(address(_postageStamp), ttl << depth);
        _postageStamp.createBatch(msg.sender, ttl, depth, minDepth, nonce, false);

        return keccak256(abi.encode(address(this), nonce));
    }

    function stampsTopUp(bytes32 batchId, uint256 ttl) public {
        // (, uint8 depth,,) = _postageStamp.batches(batchId); // v0.5
        (, uint8 depth,,,,) = _postageStamp.batches(batchId);

        _bzzToken.approve(address(_postageStamp), ttl << depth);
        _postageStamp.topUp(batchId, ttl);
    }
}
