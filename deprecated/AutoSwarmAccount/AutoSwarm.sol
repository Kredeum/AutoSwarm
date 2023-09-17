// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC6551Registry} from "lib/erc6551/src/ERC6551Registry.sol";
import {AutoSwarmAccount} from "src/AutoSwarmAccount.sol";
import {PostageStamp} from "lib/storage-incentives/src/PostageStamp.sol";

contract AutoSwarm {
    address public registry;
    address public implementation;
    address public postageStamp;
    address public bzzToken;
    uint256 public salt = uint256(keccak256("AutoSwarm V0"));
    uint256 public n;
    uint256 public constant MIN_DEPTH = 16;
    bool public constant IMMUTABLE = true;
    mapping(bytes32 => address) public batchBuyer;

    constructor(address registry_, address implementation_, address postageStamp_) {
        registry = registry_;
        implementation = implementation_;
        postageStamp = postageStamp_;
        bzzToken = PostageStamp(postageStamp).bzzToken();
    }

    function getAutoSwarmAccount(uint256 chainId, address collection, uint256 tokenId)
        external
        view
        returns (address autoSwarmAccount)
    {
        autoSwarmAccount = _getAutoSwarmAccount(chainId, collection, tokenId);
    }

    function stampsBuy(uint256 chainId, address collection, uint256 tokenId, uint256 ttl, uint8 depth)
        external
        returns (bytes32 batchId)
    {
        bytes32 nonce = keccak256(abi.encode(address(this), n++));

        address autoSwarmAccount = _getAutoSwarmAccountAndCreateIfNotExists(chainId, collection, tokenId);

        _executeApproveBzz(autoSwarmAccount, ttl << depth);
        _executeCreateBatch(autoSwarmAccount, ttl, depth, nonce);

        batchId = keccak256(abi.encode(autoSwarmAccount, nonce));

        batchBuyer[batchId] = autoSwarmAccount;
    }

    function stampsTopUp(bytes32 batchId, uint256 ttl) external {
        (, uint8 depth,,,,) = PostageStamp(postageStamp).batches(batchId);

        address autoSwarmAccount = _getAutoSwarmAccount(batchId);

        _executeApproveBzz(autoSwarmAccount, ttl << depth);
        _executeTopUp(autoSwarmAccount, batchId, ttl);
    }

    function stampsIncreaseDepth(bytes32 batchId, uint8 newDepth) external {
        address autoSwarmAccount = _getAutoSwarmAccount(batchId);

        _executeIncreaseDepth(autoSwarmAccount, batchId, newDepth);
    }

    function _getAutoSwarmAccount(uint256 chainId, address collection, uint256 tokenId)
        internal
        view
        returns (address autoSwarmAccount)
    {
        autoSwarmAccount = ERC6551Registry(registry).account(implementation, chainId, collection, tokenId, salt);
    }

    function _getAutoSwarmAccountAndCreateIfNotExists(uint256 chainId, address collection, uint256 tokenId)
        internal
        returns (address autoSwarmAccount)
    {
        autoSwarmAccount = _getAutoSwarmAccount(chainId, collection, tokenId);
        if (autoSwarmAccount.code.length == 0) {
            ERC6551Registry(registry).createAccount(implementation, chainId, collection, tokenId, salt, "");
        }
    }

    function _getAutoSwarmAccount(bytes32 batchId) internal view returns (address autoSwarmAccount) {
        autoSwarmAccount = batchBuyer[batchId];
    }

    function _executeCreateBatch(address autoSwarmAccount, uint256 ttl, uint8 depth, bytes32 nonce) internal {
        // _postageStamp.createBatch(autoSwarmAccount, ttl, depth, MIN_DEPTH, nonce, true);
        _execute(
            autoSwarmAccount,
            postageStamp,
            abi.encodeWithSignature(
                "createBatch(address,uint256,uint8,uint8,bytes32,bool)",
                autoSwarmAccount,
                ttl,
                depth,
                MIN_DEPTH,
                nonce,
                true
            )
        );
    }

    function _executeTopUp(address autoSwarmAccount, bytes32 batchId, uint256 ttl) internal {
        // postageStamp.topUp(batchId, ttl)
        _execute(autoSwarmAccount, postageStamp, abi.encodeWithSignature("topUp(bytes32,uint256)", batchId, ttl));
    }

    function _executeIncreaseDepth(address autoSwarmAccount, bytes32 batchId, uint8 depth) internal {
        // postageStamp.increaseDepth(batchId, depth);
        _execute(
            autoSwarmAccount, postageStamp, abi.encodeWithSignature("increaseDepth(bytes32,uint8)", batchId, depth)
        );
    }

    function _executeApproveBzz(address autoSwarmAccount, uint256 amount) internal {
        // bzzToken.approve(postageStamp, amount);
        _execute(autoSwarmAccount, bzzToken, abi.encodeWithSignature("approve(address,uint256)", postageStamp, amount));
    }

    function _execute(address autoSwarmAccount, address to, bytes memory data) internal {
        // AutoSwarmAccount(payable(autoSwarmAccount)).execute(to, 0, data, 0);
        (bool success, bytes memory res) = autoSwarmAccount.delegatecall(
            abi.encodeWithSignature("execute(address,uint256,bytes,uint256)", to, 0, data, 0)
        );
        require(success, "delegatecall failed");
    }
}
