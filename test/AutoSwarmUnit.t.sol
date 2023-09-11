// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {console} from "forge-std/Test.sol";
import "./SetUpAutoSwarm.t.sol";
import "forge-std/interfaces/IERC721.sol";

contract AutoSwarmUnitTest is SetUpAutoSwarm {
    function _topUp(bytes32 batchId, uint256 ttl) internal {
        (, uint8 depth,,,,) = postageStamp.batches(batchId);
        deal(address(bzzToken), address(autoSwarm), ttl << depth);
        autoSwarm.stampsTopUp(batchId, ttl);
    }

    function test_AutoSwarmUnit_OK() public pure {
        assert(true);
    }

    function test_AutoSwarmUnit_buy() public view {
        console.log("test_AutoSwarmUnit_buy ~ batchId0:");
        console.logBytes32(batchId0);
        assert(postageStamp.remainingBalance(batchId0) == ttl0);
    }

    function test_AutoSwarmUnit_remaining() public {
        uint256 lastPrice = postageStamp.lastPrice();
        vm.prank(oracle);
        postageStamp.setPrice(lastPrice + 1);

        vm.roll(postageStamp.lastUpdatedBlock() + 1);
        assert(postageStamp.remainingBalance(batchId0) < ttl0);
    }

    function test_AutoSwarmUnit_topup() public {
        uint256 ttlPlus = 1 weeks;

        _topUp(batchId0, ttlPlus);

        assert(postageStamp.remainingBalance(batchId0) == (ttl0 + ttlPlus));
    }

    function test_AutoSwarmUnit_increaseDepth_by_Batch_Owner() public {
        uint8 depthPlus = 4;

        uint256 remainingBalance = postageStamp.remainingBalance(batchId0);

        (address batchOwner,,,,,) = postageStamp.batches(batchId0);
        console.log(batchOwner, "Batch owner");

        vm.prank(batchOwner);
        postageStamp.increaseDepth(batchId0, depth0 + depthPlus);

        assert(postageStamp.remainingBalance(batchId0) == remainingBalance / (1 << depthPlus));
    }

    function test_AutoSwarmUnit_increaseDepth_by_NFT_Owner() public {
        assert(block.chainid == chainId);
        address nftOwner = IERC721(collection).ownerOf(tokenId);
        console.log(collection, "NFT collection", tokenId);
        console.log(nftOwner, "NFT owner");

        (address batchOwner,,,,,) = postageStamp.batches(batchId0);
        console.log(batchOwner, "Batch owner");

        uint8 depthPlus = 4;

        uint256 remainingBalance = postageStamp.remainingBalance(batchId0);

        vm.prank(nftOwner);
        postageStamp.increaseDepth(batchId0, depth0 + depthPlus);

        assert(postageStamp.remainingBalance(batchId0) == remainingBalance / (1 << depthPlus));
    }
}
