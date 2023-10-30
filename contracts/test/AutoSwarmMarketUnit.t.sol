// SPDX-License-Identifier: MITs
pragma solidity ^0.8.4;

import {console} from "forge-std/console.sol";
import {IERC721} from "forge-std/interfaces/IERC721.sol";

import {AutoSwarmMarket} from "@autoswarm/src/AutoSwarmMarket.sol";

contract AutoSwarmMarketHarness is SetUpAutoSwarmMarket {
    constructor(address _postageStamp) AutoSwarmMarket(_postageStamp) {
        console.log("AutoSwarmMarketUnitTest ~ constructor");
    }
}

contract AutoSwarmMarketUnitTest is AutoSwarmMarket {
    AutoSwarmMarketHarness autoSwarmMarket;
    PostageStamp postageStamp;

    function setUp() public {

    }

    function test_AutoSwarmMarket_OK() public pure {
        assert(true);
    }
}
