// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {console} from "forge-std/Test.sol";
import "./SetUpAutoSwarm.t.sol";
import "forge-std/interfaces/IERC721.sol";

contract AutoSwarmTest is SetUpAutoSwarm {
    function test_AutoSwarm_OK() public pure {
        assert(true);
    }

    function test_AutoSwarm_topUp_NFT() public {
        address accountAddress = registry.account(address(implementation), chainId, collection, tokenId, salt);
        console.log(accountAddress, "NFT Account");

        // DISPLAY NFT owner
        assert(block.chainid == chainId);
        address nftOwner = IERC721(collection).ownerOf(tokenId);
        console.log(nftOwner, "NFT owner");

        // IF NFT account NOT exists THEN create it
        if (accountAddress.code.length == 0) {
            registry.createAccount(address(implementation), chainId, collection, tokenId, salt, "");
        }
        assert(accountAddress.code.length != 0);

        // GET batch for NFT
        bytes32 batchId = setUpSwarmBatchId(accountAddress);

        // DISPLAY ttl, depth and bzz
        (address owner, uint8 depth0,,, uint256 ttl0,) = postageStamp.batches(batchId);
        uint256 bzz0 = ttl0 << depth0;
        console.log(owner, "Batch owner");
        console.log("bzz = ttl << depth : %s = %s * 2^%s", bzz0, ttl0, depth0);

        // TOPUP NFT batch ttl
        uint256 ttlPlus = 1000;
        console.log("ttlPlus", ttlPlus);
        deal(address(bzzToken), address(this), ttlPlus << depth0);
        bzzToken.approve(address(postageStamp), ttlPlus << depth0);
        postageStamp.topUp(batchId, ttlPlus);

        // DISPLAY ttl, depth and bzz
        (, uint8 depth1,,, uint256 ttl1,) = postageStamp.batches(batchId);
        uint256 bzz1 = ttl1 << depth1;
        console.log("bzz = ttl << depth : %s = %s * 2^%s", bzz1, ttl1, depth1);

        // ASSERT TOPUP OK
        assert(depth1 == depth0);
        assert(ttl1 == ttl0 + ttlPlus);
        assert(bzz1 == bzz0 + ttlPlus * (1 << depth0));

        // INCREASE NFT batch depth
        uint8 depthPlus = 4;
        console.log("depthPlus", depthPlus);
        vm.prank(postageStamp.batchOwner(batchId));
        postageStamp.increaseDepth(batchId, depth0 + depthPlus);

        // DISPLAY ttl, depth and bzz
        (, uint8 depth2,,, uint256 ttl2,) = postageStamp.batches(batchId);
        uint256 bzz2 = ttl2 << depth2;
        console.log("bzz = ttl << depth : %s = %s * 2^%s", bzz2, ttl2, depth2);

        // ASSERT INCREASE OK
        assert(depth2 == depth1 + depthPlus);
        assert(ttl2 == ttl1 / (1 << depthPlus));
        console.log("bzz2 ~= bzz1  :  %s ~= %s", bzz2, bzz1);
    }
}
