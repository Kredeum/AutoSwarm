// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {console} from "forge-std/Test.sol";
import "./SetUpAutoSwarm.t.sol";

contract AutoSwarmTest is SetUpAutoSwarm {
    function test_AutoSwarm_OK() public pure {
        assert(true);
    }

    function test_AutoSwarm_topUp_NFT() public {
        address accountAddress = registry.account(address(implementation), chainId, collection, tokenId, salt);

        // IF NFT account NOT exists THEN create it
        if (accountAddress.code.length == 0) {
            registry.createAccount(address(implementation), chainId, collection, tokenId, salt, "");
        }
        assert(accountAddress.code.length != 0);

        // GET batch for NFT
        bytes32 batchId = setUpSwarmBatchId(accountAddress);

        // Display ttl and volume
        (address owner, uint8 depth,,, uint256 normalisedBalance,) = postageStamp.batches(batchId);
        console.log(owner, "Batch        Owner");
        console.log("depth  ", depth);
        console.log("ttl    ", normalisedBalance);

        // topUp NFT, by increasing ttlPlus
        uint256 ttlPlus = 1000;
        console.log("ttlplus   ", ttlPlus);
        deal(address(bzzToken), address(this), ttlPlus << depth);

        bzzToken.approve(address(postageStamp), ttlPlus << depth);
        postageStamp.topUp(batchId, ttlPlus);

        // Display ttl
        (,,,, normalisedBalance,) = postageStamp.batches(batchId);
        console.log("ttl    ", normalisedBalance);
    }
}
