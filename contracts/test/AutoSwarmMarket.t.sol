// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {console} from "forge-std/console.sol";
import {IERC721} from "forge-std/interfaces/IERC721.sol";

import {SetUpAutoSwarmMarket} from "./SetUpAutoSwarmMarket.t.sol";

contract AutoSwarmMarketTest is SetUpAutoSwarmMarket {
    function test_AutoSwarmMarket_OK() external pure {
        assert(true);
    }

    function test_AutoSwarmMarket_addBatch() external {
        vm.prank(deployer);
        autoSwarmMarket.addBatch(batchId0);
        assert(autoSwarmMarket.batchIds(0) == batchId0);
    }

    function test_AutoSwarmMarket_buyStamp() external {
        autoSwarmMarket.buyStamp(40_960, 1 days);
        assert(true);
    }
}
