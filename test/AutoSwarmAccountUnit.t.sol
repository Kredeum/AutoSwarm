// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {console} from "forge-std/Test.sol";
import "./SetUpAutoSwarmAccount.t.sol";
import {IERC721} from "forge-std/interfaces/IERC721.sol";

contract AutoSwarmAccountUnitTest is SetUpAutoSwarmAccount {
    function test_AutoSwarmAccountUnit_OK() public view {
        console.log("test_AutoSwarmAccountUnit_stampsBuy ~ autoSwarmAccount:", address(autoSwarmAccount));
        assert(true);
    }

    function test_AutoSwarmAccountUnit_Create() public {
        address account = registry.account(address(implementation), chainId, collection, tokenId, salt);

        if (account.code.length == 0) {
            registry.createAccount(address(implementation), chainId, collection, tokenId, salt, "");
        }
        assert(account.code.length != 0);
    }

    function test_AutoSwarmAccount_nonce() public {
        bytes32 salt1 = autoSwarmAccount._newNonce();
        assert(salt1 != "");
        bytes32 salt2 = autoSwarmAccount._newNonce();
        assert(salt2 != salt1);
    }

    function test_AutoSwarmAccount_token() public view {
        (uint256 chId, address coll, uint256 tokId) = AutoSwarmAccount(payable(autoSwarmAccount)).token();

        assert(chId == chainId);
        assert(coll == collection);
        assert(tokId == tokenId);
    }

    function test_AutoSwarmAccountUnit_stampsBuy() public {
        uint256 ttl = 10 weeks;
        uint8 depth = 20;

        deal(address(bzzToken), address(autoSwarmAccount), ttl << depth);
        bytes32 batchId = autoSwarmAccount.stampsBuy(ttl, depth);
        console.logBytes32(batchId);

        assert(postageStamp.remainingBalance(batchId) == ttl);
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
