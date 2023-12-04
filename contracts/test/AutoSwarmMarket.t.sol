// SPDX-License-Identifier: MITs
pragma solidity ^0.8.4;

import {console} from "forge-std/console.sol";
import {IERC721} from "forge-std/interfaces/IERC721.sol";

import {SetUpAutoSwarmMarket} from "@autoswarm/test/setup/SetUpAutoSwarmMarket.t.sol";

contract AutoSwarmMarketTest is SetUpAutoSwarmMarket {
    function test_AutoSwarmMarket_OK() public pure {
        assert(true);
    }
}
