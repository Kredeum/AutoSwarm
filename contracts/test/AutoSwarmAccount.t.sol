// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {console} from "forge-std/console.sol";
import {IERC721} from "forge-std/interfaces/IERC721.sol";

import {SetUpAutoSwarmAccount} from "@autoswarm/test/SetUpAutoSwarmAccount.t.sol";

contract AutoSwarmAccountTest is SetUpAutoSwarmAccount {
    function test_AutoSwarmAccount_OK() public pure {
        assert(true);
    }

    function test_AutoSwarmAccount_topUp_NFT() public {
        address accountAddress = registry.account(address(implementation), chainId, collection, tokenId, salt);
        console.log(accountAddress, "NFT Account");

        // DISPLAY NFT owner
        assert(block.chainid == chainId);
        address nftOwner = IERC721(collection).ownerOf(tokenId);
        console.log(nftOwner, "NFT owner");

        vm.startPrank(nftOwner);

        // CREATE NFT Account if not already exists
        if (accountAddress.code.length == 0) {
            registry.createAccount(address(implementation), chainId, collection, tokenId, salt, "");
        }
        assert(accountAddress.code.length != 0);

        // BUY batch for NFT
        uint256 ttl = 10 weeks;
        uint8 depth = 20;
        uint256 bzz = ttl << depth;
        deal(address(bzzToken), nftOwner, bzz);
        bzzToken.transfer(address(autoSwarmAccount), bzz);
        bytes32 batchId = autoSwarmAccount.stampsBuy(ttl, depth);

        // DISPLAY ttl, depth and bzz
        (address owner, uint8 depth0,,, uint256 ttl0,) = postageStamp.batches(batchId);
        uint256 bzz0 = ttl0 << depth0;
        console.log(owner, "Batch owner");
        console.log("bzz = ttl << depth : %s = %s * 2^%s", bzz0, ttl0, depth0);

        // ASSERT BUY
        assert(bzz0 == bzz);
        assert(ttl0 == ttl);
        assert(depth0 == depth);
        assert(owner == address(autoSwarmAccount));

        // TOPUP NFT batch ttl
        uint256 ttlPlus = 1000;
        uint256 bzzPlus = ttlPlus << depth0;
        console.log("ttlPlus", ttlPlus);
        deal(address(bzzToken), nftOwner, bzzPlus);
        bzzToken.transfer(address(autoSwarmAccount), bzzPlus);
        autoSwarmAccount.stampsTopUp(batchId, ttlPlus);

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
        autoSwarmAccount.stampsIncreaseDepth(batchId, depth0 + depthPlus);

        // DISPLAY ttl, depth and bzz
        (, uint8 depth2,,, uint256 ttl2,) = postageStamp.batches(batchId);
        uint256 bzz2 = ttl2 << depth2;
        console.log("bzz = ttl << depth : %s = %s * 2^%s", bzz2, ttl2, depth2);

        // ASSERT INCREASE OK
        assert(depth2 == depth1 + depthPlus);
        assert(ttl2 == ttl1 / (1 << depthPlus));
        console.log("bzz2 ~= bzz1  :  %s ~= %s", bzz2, bzz1);

        vm.stopPrank();
    }
}
