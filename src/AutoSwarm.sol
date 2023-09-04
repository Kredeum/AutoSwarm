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

    function stampsCreate(uint256 ttl, uint8 depth) public returns (bytes32 batchId) {
        bytes32 nonce = keccak256(abi.encode(msg.sender, _salt));

        uint256 bzzAmount = ttl * (1 << depth);
        _bzzToken.approve(address(_postageStamp), bzzAmount);

        _postageStamp.createBatch(msg.sender, ttl, depth, 16, nonce, true);

        batchId = keccak256(abi.encode(address(this), nonce));

        _salt++;
    }
}
