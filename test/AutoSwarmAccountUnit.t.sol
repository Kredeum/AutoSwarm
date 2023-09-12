// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {console} from "forge-std/Test.sol";
import "./SetUpAutoSwarmAccount.t.sol";
import "forge-std/interfaces/IERC721.sol";

contract AutoSwarmAccountUnitTest is SetUpAutoSwarmAccount {
    function test_AutoSwarmAccountUnit_OK() public pure {
        assert(true);
    }

    function test_AutoSwarmAccountUnit_buy() public {
        uint256 ttl = 10 weeks;
        uint8 depth = 20;

        deal(address(bzzToken), address(autoSwarmAccount), ttl << depth);
        bytes32 batchId = autoSwarmAccount.stampsBuy(ttl, depth);

        assert(postageStamp.remainingBalance(batchId) == ttl);
    }

    function test_AutoSwarmAccountUnit_remaining() public {
        uint256 lastPrice = postageStamp.lastPrice();
        vm.prank(oracle);
        postageStamp.setPrice(lastPrice + 1);

        vm.roll(postageStamp.lastUpdatedBlock() + 1);
        assert(postageStamp.remainingBalance(batchId0) < ttl0);
    }

    function test_AutoSwarmAccountUnit_topUp() public {
        uint256 ttlPlus = 1 weeks;

        (, uint8 depth,,,,) = postageStamp.batches(batchId0);
        deal(address(bzzToken), address(autoSwarmAccount), ttlPlus << depth);
        autoSwarmAccount.stampsTopUp(batchId0, ttlPlus);

        assert(postageStamp.remainingBalance(batchId0) == (ttl0 + ttlPlus));
    }

    function test_AutoSwarmAccountUnit_increaseDepth_by_Batch_Owner() public {
        uint8 depthPlus = 4;

        uint256 remainingBalance = postageStamp.remainingBalance(batchId0);

        (address batchOwner,,,,,) = postageStamp.batches(batchId0);
        console.log(batchOwner, "Batch owner");

        vm.prank(batchOwner);
        postageStamp.increaseDepth(batchId0, depth0 + depthPlus);

        assert(postageStamp.remainingBalance(batchId0) == remainingBalance / (1 << depthPlus));
    }

    function test_AutoSwarmAccountUnit_increaseDepth_by_NFT_Owner() public {
        assert(block.chainid == chainId);
        address nftOwner = IERC721(collection).ownerOf(tokenId);
        console.log(collection, "NFT collection", tokenId);
        console.log(nftOwner, "NFT owner");

        (address batchOwner,,,,,) = postageStamp.batches(batchId0);
        console.log(batchOwner, "Batch owner");

        uint8 depthPlus = 4;

        uint256 remainingBalance = postageStamp.remainingBalance(batchId0);

        vm.prank(nftOwner);
        autoSwarmAccount.stampsIncreaseDepth(batchId0, depth0 + depthPlus);

        assert(postageStamp.remainingBalance(batchId0) == remainingBalance / (1 << depthPlus));
    }
}
