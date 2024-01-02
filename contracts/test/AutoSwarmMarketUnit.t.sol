// SPDX-License-Identifier: MITs
pragma solidity 0.8.23;

import {console} from "forge-std/console.sol";
import {IERC721} from "forge-std/interfaces/IERC721.sol";

import {AutoSwarmMarket} from "@autoswarm/src/AutoSwarmMarket.sol";
import {SetUpAutoSwarmMarket} from "@autoswarm/test/setup/SetUpAutoSwarmMarket.t.sol";

contract AutoSwarmMarketUnitTest is SetUpAutoSwarmMarket {
    function test_AutoSwarmMarketUnit_OK() public pure {
        assert(true);
    }

    function test_AutoSwarmMarketUnit_Math(uint256 depth, uint256 bzzAmount) public pure {
        vm.assume(depth < 32);

        assert((bzzAmount >> depth) << depth == (bzzAmount - bzzAmount % (1 << depth)));
    }

    function test_AutoSwarmMarketUnit_getStampsToAttach0() public view {
        bytes32[] memory stampIds = autoSwarmMarket.getStampIdsToAttach(0, 0);
        assert(stampIds.length == 0);
    }

    function test_AutoSwarmMarketUnit_getStampsToAttach1() public {
        // uint256 stampsTotalOutPayment0 = autoSwarmMarket.stampsTotalOutPayment();

        deal(address(bzzToken), address(this), 4);
        bzzToken.approve(address(autoSwarmMarket), 4);
        autoSwarmMarket.createStamp("1", 1, 4);

        // uint256 stampsTotalOutPayment1 = autoSwarmMarket.stampsTotalOutPayment();

        bytes32[] memory stampIds = autoSwarmMarket.getStampIdsToAttach(0, 1);
        assert(stampIds.length == 1);
        (bytes32 swarmHash, uint256 swarmSize, bytes32 batchId, uint256 unitBalance) =
            autoSwarmMarket.stamps(stampIds[0]);

        assert(swarmHash == "1");
        assert(swarmSize == 1);
        assert(batchId == "");
        assert(unitBalance == 4);
    }

    function test_AutoSwarmMarketUnit_getStampsToAttach2() public {
        deal(address(bzzToken), address(this), 7);
        bzzToken.approve(address(autoSwarmMarket), 7);

        autoSwarmMarket.createStamp("1", 1, 3);
        autoSwarmMarket.createStamp("2", 1, 4);

        assert(autoSwarmMarket.getStampIdsToAttach(0, 0).length == 0);
        assert(autoSwarmMarket.getStampIdsToAttach(0, 2).length == 2);
        assert(autoSwarmMarket.getStampIdsToAttach(1, 1).length == 1);

        vm.expectRevert();
        autoSwarmMarket.createStamp("3", 1, 1);
    }

    function test_AutoSwarmMarketUnit_setStampsAttached() public {
        deal(address(bzzToken), address(this), 2);
        bzzToken.approve(address(autoSwarmMarket), 2);

        autoSwarmMarket.createStamp("1", 1, 1);
        autoSwarmMarket.createStamp("2", 1, 1);
        bytes32[] memory stampIds = autoSwarmMarket.getStampIdsToAttach(0, 2);

        // upload / sync swarm hash to node on currentBatchid

        vm.prank(deployer);
        autoSwarmMarket.attachStamps(stampIds);
    }
}
