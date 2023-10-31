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

        deal(address(bzzToken), address(this), 1);
        bzzToken.approve(address(autoSwarmMarket), 1);
        autoSwarmMarket.createStamp("1", 1, 1);

        uint256 currentStampUnitPaid1 = autoSwarmMarket.currentStampUnitPaid();

        bytes32[] memory stampIds = autoSwarmMarket.getStampIdsToAttach(0, 1);
        assert(stampIds.length == 1);
        AutoSwarmMarket.Stamp memory stamp = autoSwarmMarket.getStamp(stampIds[0]);

        assert(stamp.owner == address(this));
        assert(stamp.swarmHash == "1");
        assert(stamp.swarmSize == 1);
        assert(stamp.batchId == "");
        assert(stamp.unitBalance == 1);
    }

    function test_AutoSwarmMarketUnit_setStampsAttached() public {
        bytes32 currentBatchId = autoSwarmMarket.currentBatchId();

        deal(address(bzzToken), address(this), 2);
        bzzToken.approve(address(autoSwarmMarket), 2);

        autoSwarmMarket.createStamp("1", 1, 1);
        autoSwarmMarket.createStamp("2", 1, 1);
        bytes32[] memory stampIds = autoSwarmMarket.getStampIdsToAttach(0, 2);

        autoSwarmMarket.setStampsAttached(stampIds, currentBatchId);
    }

    function test_AutoSwarmMarketUnit_getStampsToAttach2() public {
        deal(address(bzzToken), address(this), 2);
        bzzToken.approve(address(autoSwarmMarket), 2);

        autoSwarmMarket.createStamp("1", 1, 1);
        autoSwarmMarket.createStamp("2", 1, 1);

        assert(autoSwarmMarket.getStampIdsToAttach(0, 0).length == 0);
        assert(autoSwarmMarket.getStampIdsToAttach(0, 2).length == 2);
        assert(autoSwarmMarket.getStampIdsToAttach(1, 1).length == 1);

        vm.expectRevert();
        autoSwarmMarket.createStamp("3", 1, 1);

        vm.expectRevert();
        autoSwarmMarket.getStampIdsToAttach(0, 3);

        vm.expectRevert();
        autoSwarmMarket.getStampIdsToAttach(1, 5);

        vm.expectRevert();
        autoSwarmMarket.getStampIdsToAttach(3, 4);
    }
}
