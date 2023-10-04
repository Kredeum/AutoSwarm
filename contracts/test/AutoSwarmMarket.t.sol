// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {console} from "forge-std/console.sol";
import {IERC721} from "forge-std/interfaces/IERC721.sol";

import {SetUpAutoSwarmMarket} from "./SetUpAutoSwarmMarket.t.sol";

contract AutoSwarmMarketTest is SetUpAutoSwarmMarket {
    function test_AutoSwarmMarket_OK() external pure {
        assert(true);
    }

    function testFails_AutoSwarmMarket_buyBatch() external {
        deal(address(bzzToken), address(autoSwarmMarket), initTtl << initDepth);
        autoSwarmMarket.buyBatch(initYear);
    }

    function test_AutoSwarmMarket_buyBatch() external {
        uint256 year = autoSwarmMarket.nextYear();

        deal(address(bzzToken), address(autoSwarmMarket), initTtl << initDepth);

        vm.prank(deployer);
        autoSwarmMarket.buyBatch(year);

        assert(autoSwarmMarket.getBatchTtl(year) == initTtl);
        assert(autoSwarmMarket.getBatchDepth(year) == initDepth);
    }

    function test_AutoSwarmMarket_topUpBatch() external {
        uint256 ttl = 1e10;

        deal(address(bzzToken), address(autoSwarmMarket), ttl << initDepth);

        vm.prank(deployer);
        autoSwarmMarket.topUpBatch(initYear, ttl);

        assert(autoSwarmMarket.getBatchTtl(initYear) == initTtl + ttl);
        assert(autoSwarmMarket.getBatchDepth(initYear) == initDepth);
    }

    function test_AutoSwarmMarket_diluteBatch() external {
        uint8 deltaDepth = 2;

        vm.prank(deployer);
        autoSwarmMarket.diluteBatch(initYear, deltaDepth);

        assert(autoSwarmMarket.getBatchTtl(initYear) == initTtl / (1 << deltaDepth));
        assert(autoSwarmMarket.getBatchDepth(initYear) == initDepth + deltaDepth);
    }

    function test_AutoSwarmMarket_extendsBatch() external {
        uint8 newDepth = initDepth + 2;
        uint256 mul = 1 << (newDepth - initDepth);

        deal(address(bzzToken), address(autoSwarmMarket), ((initTtl * (mul - 1)) / mul) << newDepth);
        vm.prank(deployer);
        autoSwarmMarket.extendsBatch(initYear, newDepth - initDepth);

        assert(autoSwarmMarket.getBatchTtl(initYear) == initTtl);
        assert(autoSwarmMarket.getBatchDepth(initYear) == newDepth);
    }
}
