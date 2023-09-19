// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {PostageStamp} from "lib/storage-incentives/src/PostageStamp.sol";
import {SimpleERC6551Account} from "lib/erc6551/src/examples/simple/SimpleERC6551Account.sol";
import {ERC6551Registry} from "lib/erc6551/src/ERC6551Registry.sol";
import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";

interface IPostageStampLegacy {
    function batches(bytes32) external returns (address, uint8, bool, uint256);
}

contract AutoSwarmAccount is SimpleERC6551Account {
    PostageStamp internal _postageStamp;
    IERC20 internal _bzzToken;
    uint8 internal _minDepth;
    uint256 internal _n;

    function initialize(address payable postageStamp_) external {
        _postageStamp = PostageStamp(postageStamp_);
        _minDepth = _postageStamp.minimumBucketDepth();
        _bzzToken = IERC20(_postageStamp.bzzToken());
    }

    function stampsBuy(uint256 ttl, uint8 depth) public returns (bytes32) {
        bytes32 nonce = keccak256(abi.encode(address(this), _n++));

        _bzzToken.approve(address(_postageStamp), ttl << depth);
        _postageStamp.createBatch(address(this), ttl, depth, _minDepth, nonce, false);

        return keccak256(abi.encode(address(this), nonce));
    }

    function stampsTopUp(bytes32 batchId, uint256 ttl) public {
        uint8 depth;
        if (block.chainid == 100) {
            (, depth,,) = IPostageStampLegacy(address(_postageStamp)).batches(batchId);
        } else {
            (, depth,,,,) = _postageStamp.batches(batchId);
        }

        _bzzToken.approve(address(_postageStamp), ttl << depth);
        _postageStamp.topUp(batchId, ttl);
    }

    function stampsIncreaseDepth(bytes32 batchId, uint8 newDepth) external {
        _postageStamp.increaseDepth(batchId, newDepth);
    }

    function withdraw(address token) external {
        IERC20(token).transfer(owner(), IERC20(token).balanceOf(address(this)));
        (bool success,) = owner().call{value: address(this).balance}("");
        require(success, "Withdraw failed!");
    }
}
