// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";

import {SetUpAutoSwarmMarket} from "@autoswarm/test/SetUpAutoSwarmMarket.t.sol";

contract SetUpAutoSwarmMarketTest is SetUpAutoSwarmMarket {
    function setUp() public {
        setUpERC6551();
        setUpSwarm();
        setUpAutoSwarmAccount();
        setUpAutoSwarmMarket();
    }

    function test_SetUpAutoSwarmMarket_OK() public pure {
        assert(true);
    }
}
