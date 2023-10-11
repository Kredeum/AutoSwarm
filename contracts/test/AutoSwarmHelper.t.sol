// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {console} from "forge-std/Test.sol";
import {IERC721} from "forge-std/interfaces/IERC721.sol";

import {AutoSwarmAccount} from "@autoswarm/src/AutoSwarmAccount.sol";
import {SetUpAutoSwarmHelper} from "@autoswarm/test/SetUpAutoSwarmHelper.t.sol";
import {AutoSwarmHelper} from "@autoswarm/src/AutoSwarmHelper.sol";

contract AutoSwarmHelperTest is SetUpAutoSwarmHelper {
    function test_AutoSwarmHelper_OK() public view {
        assert(true);
    }

    function setConfigNftOwner() public {
        AutoSwarmHelper.Config memory config =
            AutoSwarmHelper.Config(nftOwner, address(registry), address(implementation), address(postageStamp));

        autoSwarmHelper.setConfig(config);
    }

    function test_AutoSwarmHelper_setConfig() public {
        AutoSwarmHelper.Config memory config =
            AutoSwarmHelper.Config(nftOwner, address(registry), address(implementation), address(postageStamp));

        autoSwarmHelper.setConfig(config);
        AutoSwarmHelper.Config memory cfg = autoSwarmHelper.getConfig();

        console.log("test_AutoSwarmHelper_setConfig ~ msg.sender:", msg.sender);
        console.log("test_AutoSwarmHelper_setConfig ~ config.owner:", config.owner);
        console.log("test_AutoSwarmHelper_setConfig ~ cfg.registry:", cfg.registry);
        console.log("test_AutoSwarmHelper_setConfig ~ cfg.implementation:", cfg.implementation);
        console.log("test_AutoSwarmHelper_setConfig ~ cfg.postageStamp:", cfg.postageStamp);
        assert(cfg.owner == nftOwner);
        assert(cfg.registry == config.registry);
        assert(cfg.implementation == config.implementation);
        assert(cfg.postageStamp == config.postageStamp);

        vm.expectRevert();
        autoSwarmHelper.setConfig(config);

        vm.prank(nftOwner);
        autoSwarmHelper.setConfig(config);
    }

    function test_AutoSwarmHelper_initialize() public {
        setConfigNftOwner();

        vm.prank(nftOwner);
        address tba = autoSwarmHelper.getAccountOrCreate(chainId, collection, tokenId);

        address me = AutoSwarmAccount(payable(tba)).me();
        assert(me == tba);

        (uint256 chId, address coll, uint256 tokId) = AutoSwarmAccount(payable(tba)).token();
        assert(tba.code.length != 0);
        assert(chId == chainId);
        assert(coll == collection);
        assert(tokId == tokenId);
    }

    function test_AutoSwarmHelper_ApproveBzz() public {
        setConfigNftOwner();

        vm.prank(nftOwner);
        address autoSwarmAccount = autoSwarmHelper.getAccountOrCreate(chainId, collection, tokenId);

        (uint256 chId, address coll, uint256 tokId) = AutoSwarmAccount(payable(autoSwarmAccount)).token();
        assert(autoSwarmAccount.code.length != 0);
        assert(chId == chainId);
        assert(coll == collection);
        assert(tokId == tokenId);

        assert(bzzToken.balanceOf(autoSwarmAccount) == 0);
        deal(address(bzzToken), autoSwarmAccount, 1);
        assert(bzzToken.balanceOf(autoSwarmAccount) == 1);

        console.log(
            address(implementation),
            "test_AutoSwarmHelper_ApproveBzz ~ implementation",
            address(implementation).code.length
        );
        console.log(
            autoSwarmAccount, "test_AutoSwarmHelper_ApproveBzz ~ autoSwarmAccount", autoSwarmAccount.code.length
        );
        console.log(msg.sender, "test_AutoSwarmHelper_ApproveBzz msg.sender");
        console.log(address(this), "test_AutoSwarmHelper_ApproveBzz this AutoSwarmTest");
        console.log(address(autoSwarmHelper), "test_AutoSwarmHelper_ApproveBzz autoSwarmHelper");
        console.log(nftOwner, "test_AutoSwarmHelper_ApproveBzz nftOwner");

        assert(bzzToken.allowance(autoSwarmAccount, address(postageStamp)) == 0);

        vm.startPrank(nftOwner);
        autoSwarmHelper.approveBzz(autoSwarmAccount, address(postageStamp), 1);
        vm.stopPrank();

        assert(bzzToken.allowance(autoSwarmAccount, address(postageStamp)) == 1);
    }

    // function test_AutoSwarm_topUp() public {
    //     uint256 ttlPlus = 1 weeks;

    //     (, uint8 depth,,,,) = postageStamp.batches(batchId0);
    //     deal(address(bzzToken), address(autoSwarmAccount), ttlPlus << depth);

    //     vm.prank(nftOwner);
    //     autoSwarmAccount.stampsTopUp(batchId0, ttlPlus);

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
    //     autoSwarmAccount.stampsIncreaseDepth(batchId0, depth0 + depthPlus);

    //     assert(postageStamp.remainingBalance(batchId0) == remainingBalance / (1 << depthPlus));
    // }
}
