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
        autoSwarmMarket.buyBatch(year);

        assert(autoSwarmMarket.getBatchTtl(year) == initTtl);
        assert(autoSwarmMarket.getBatchDepth(year) == initDepth);
    }

    function test_AutoSwarmMarket_extandsbatch() external {
        uint8 newDepth = 25;
        uint256 mul = 1 << (newDepth - initDepth);

        deal(address(bzzToken), address(autoSwarmMarket), ((initTtl * (mul - 1)) / mul) << newDepth);
        autoSwarmMarket.extendsBatch(initYear, newDepth);

        assert(true);
    }
}
