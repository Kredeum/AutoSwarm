// SPDX-License-Identifier: MITs
pragma solidity ^0.8.4;

import {console} from "forge-std/console.sol";
import {IERC721} from "forge-std/interfaces/IERC721.sol";

import {AutoSwarmMarket} from "@autoswarm/src/AutoSwarmMarket.sol";
import {SetUpAutoSwarmMarket} from "@autoswarm/test/setup/SetUpAutoSwarmMarket.t.sol";

contract AutoSwarmMarketUnitTest is SetUpAutoSwarmMarket {
    function test_AutoSwarmMarketUnit_OK() public pure {
        assert(true);
    }

    function test_AutoSwarmMarketUnit_getStampsToAttach0() public view {
        bytes32[] memory stampIds = autoSwarmMarket.getStampIdsToAttach(0, 0);
        assert(stampIds.length == 0);
    }

    function test_AutoSwarmMarketUnit_getStampsToAttach1() public {
        uint256 currentStampUnitPaid0 = autoSwarmMarket.currentStampUnitPaid();
        console.log("test_AutoSwarmMarketUnit_getStampsToAttach1 ~ currentStampUnitPaid0:", currentStampUnitPaid0);

        deal(address(bzzToken), address(this), 4);
        bzzToken.approve(address(autoSwarmMarket), 4);
        autoSwarmMarket.createStamp("1", 4);

        uint256 currentStampUnitPaid1 = autoSwarmMarket.currentStampUnitPaid();
        console.log("test_AutoSwarmMarketUnit_getStampsToAttach1 ~ currentStampUnitPaid1:", currentStampUnitPaid1);

        bytes32[] memory stampIds = autoSwarmMarket.getStampIdsToAttach(0, 1);
        assert(stampIds.length == 1);
        AutoSwarmMarket.Stamp memory stamp = autoSwarmMarket.getStamp(stampIds[0]);

        assert(stamp.owner == address(this));
        assert(stamp.bzzHash == "1");
        assert(stamp.swarmSize == 1);
        assert(stamp.batchId == "");
        assert(stamp.unitBalance == 4);
    }

    function test_AutoSwarmMarketUnit_getStampsToAttach2() public {
        deal(address(bzzToken), address(this), 7);
        bzzToken.approve(address(autoSwarmMarket), 7);

        autoSwarmMarket.createStamp("1", 3);
        autoSwarmMarket.createStamp("2", 4);

        assert(autoSwarmMarket.getStampIdsToAttach(0, 0).length == 0);
        assert(autoSwarmMarket.getStampIdsToAttach(0, 2).length == 2);
        assert(autoSwarmMarket.getStampIdsToAttach(1, 1).length == 1);

        vm.expectRevert();
        autoSwarmMarket.createStamp("3", 1);

        vm.expectRevert();
        autoSwarmMarket.getStampIdsToAttach(0, 3);

        vm.expectRevert();
        autoSwarmMarket.getStampIdsToAttach(1, 5);

        vm.expectRevert();
        autoSwarmMarket.getStampIdsToAttach(3, 4);
    }

    function test_AutoSwarmMarketUnit_setStampsAttached() public {
        deal(address(bzzToken), address(this), 2);
        bzzToken.approve(address(autoSwarmMarket), 2);

        autoSwarmMarket.createStamp("1", 1);
        autoSwarmMarket.createStamp("2", 1);
        bytes32[] memory stampIds = autoSwarmMarket.getStampIdsToAttach(0, 2);

        // upload / sync swarm hash to node on currentBatchid

        bytes32 currentBatchId = autoSwarmMarket.currentBatchId();
        autoSwarmMarket.setStampsAttached(stampIds, currentBatchId);
    }
}
