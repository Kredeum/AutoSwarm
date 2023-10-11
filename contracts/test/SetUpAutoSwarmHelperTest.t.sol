// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {AutoSwarmHelper} from "@autoswarm/src/AutoSwarmHelper.sol";

import {SetUpAutoSwarmHelper} from "@autoswarm/test/SetUpAutoSwarmHelper.t.sol";

import {console} from "forge-std/console.sol";

contract SetUpAutoSwarmHelperTest is SetUpAutoSwarmHelper {
    function test_SetUpAutoSwarmHelper_OK() public pure {
        assert(true);
    }
}
