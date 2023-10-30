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
        AutoSwarmMarket.Stamp[] memory stamps = autoSwarmMarket.getStampsToAttach(0, 0);
        assert(stamps.length == 0);
    }

    function test_AutoSwarmMarketUnit_getStampsToAttach1() public {
        uint256 currentStampUnitPaid0 = autoSwarmMarket.currentStampUnitPaid();
        console.log("test_AutoSwarmMarketUnit_getStampsToAttach1 ~ currentStampUnitPaid0:", currentStampUnitPaid0);
        console.log("test_AutoSwarmMarketUnit_getStampsToAttach1 ~ stampUnitPrice:", autoSwarmMarket.stampUnitPrice());
        console.log(
            "test_AutoSwarmMarketUnit_getStampsToAttach1 ~ stampBlockUpdate:", autoSwarmMarket.stampBlockUpdate()
        );
        console.log("test_AutoSwarmMarketUnit_getStampsToAttach1 ~ block.number:", block.number);

        deal(address(bzzToken), address(this), 1);
        bzzToken.approve(address(autoSwarmMarket), 1);
        autoSwarmMarket.createStamp("1", 1, 1);

        uint256 currentStampUnitPaid1 = autoSwarmMarket.currentStampUnitPaid();
        console.log("test_AutoSwarmMarketUnit_getStampsToAttach1 ~ currentStampUnitPaid1:", currentStampUnitPaid1);

        AutoSwarmMarket.Stamp[] memory stamps = autoSwarmMarket.getStampsToAttach(0, 1);
        assert(stamps.length == 1);

        console.log("test_AutoSwarmMarketUnit_getStampsToAttach1 ~ stamps[0].owner:", stamps[0].owner);
        console.log("test_AutoSwarmMarketUnit_getStampsToAttach1 ~ stamps[0].swarmSize:", stamps[0].swarmSize);
        console.logBytes32(stamps[0].swarmHash);
        console.logBytes32(stamps[0].batchId);
        console.log("test_AutoSwarmMarketUnit_getStampsToAttach1 ~ stamps[0].unitBalance:", stamps[0].unitBalance);
        assert(stamps[0].owner == address(this));
        assert(stamps[0].swarmHash == "1");
        assert(stamps[0].swarmSize == 1);
        assert(stamps[0].batchId == "");
        assert(stamps[0].unitBalance == 1);
    }

    function test_AutoSwarmMarketUnit_getStampsToAttach2() public {
        deal(address(bzzToken), address(this), 2);
        bzzToken.approve(address(autoSwarmMarket), 2);

        autoSwarmMarket.createStamp("1", 1, 1);
        autoSwarmMarket.createStamp("2", 1, 1);

        assert(autoSwarmMarket.getStampsToAttach(0, 0).length == 0);
        assert(autoSwarmMarket.getStampsToAttach(0, 1).length == 1);
        assert(autoSwarmMarket.getStampsToAttach(1, 1).length == 1);

        vm.expectRevert();
        autoSwarmMarket.createStamp("3", 1, 1);

        vm.expectRevert();
        autoSwarmMarket.getStampsToAttach(0, 3);

        vm.expectRevert();
        autoSwarmMarket.getStampsToAttach(1, 5);

        vm.expectRevert();
        autoSwarmMarket.getStampsToAttach(3, 4);
    }
}
