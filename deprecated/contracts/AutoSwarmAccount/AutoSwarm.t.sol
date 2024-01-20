// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {console} from "forge-std/Test.sol";
import "./SetUpAutoSwarm.t.sol";
import {IERC721} from "forge-std/interfaces/IERC721.sol";

contract AutoSwarmTest is SetUpAutoSwarm {
    function test_AutoSwarm_OK() public view {
        assert(true);
    }

    function test_AutoSwarm_stampsBuy() public {
        uint256 ttl = 10 weeks;
        uint8 depth = 20;

        vm.prank(nftOwner);
        registry.createAccount(address(implementation), chainId, collection, tokenId, salt, "");

        address autoSwarmAccount = registry.account(address(implementation), chainId, collection, tokenId, salt);
        (uint256 chId, address coll, uint256 tokId) = AutoSwarmAccount(payable(autoSwarmAccount)).token();
        assert(autoSwarmAccount.code.length != 0);
        assert(chId == chainId);
        assert(coll == collection);
        assert(tokId == tokenId);
        console.log(autoSwarmAccount, "AutoSwarmTest ~ autoSwarmAccount");
        console.logBytes(autoSwarmAccount.code);
        console.log("test_AutoSwarm_stampsBuy ~ autoSwarmAccount.code.length:", autoSwarmAccount.code.length);

        deal(address(bzzToken), autoSwarmAccount, ttl << depth);

        vm.startPrank(nftOwner);
        bytes32 batchId = autoSwarm.stampsBuy(chainId, collection, tokenId, ttl, depth);
        vm.stopPrank();

        assert(postageStamp.remainingBalance(batchId) == ttl);
    }

    // function test_AutoSwarm_topUp() public {
    //     uint256 ttlPlus = 1 weeks;

    //     (, uint8 depth,,,,) = postageStamp.batches(batchId0);
    //     deal(address(bzzToken), address(autoSwarmAccount), ttlPlus << depth);

    //     vm.prank(nftOwner);
    //     autoSwarm.stampsTopUp(batchId0, ttlPlus);

    //     assert(postageStamp.remainingBalance(batchId0) == (ttl0 + ttlPlus));
    // }

    // function test_AutoSwarm_increaseDepth() public {
    //     assert(block.chainid == chainId);
    //     address nftOwner = IERC721(collection).ownerOf(tokenId);
    //     console.log(collection, "NFT collection", tokenId);
    //     console.log(nftOwner, "NFT owner");

    //     (address batchOwner,,,,,) = postageStamp.batches(batchId0);
    //     console.log(batchOwner, "Batch owner");

    //     uint8 depthPlus = 4;

    //     uint256 remainingBalance = postageStamp.remainingBalance(batchId0);

    //     vm.prank(nftOwner);
    //     autoSwarm.stampsIncreaseDepth(batchId0, depth0 + depthPlus);

    //     assert(postageStamp.remainingBalance(batchId0) == remainingBalance / (1 << depthPlus));
    // }
}
