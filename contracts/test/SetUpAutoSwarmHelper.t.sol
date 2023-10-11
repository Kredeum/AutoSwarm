// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {SetUpAutoSwarmAccount} from "@autoswarm/test/SetUpAutoSwarmAccount.t.sol";
import {SetUpSwarm} from "@autoswarm/test/SetUpSwarm.t.sol";
import {SetUpERC6551} from "@autoswarm/test/SetUpERC6551.t.sol";
import {AutoSwarmHelper} from "@autoswarm/src/AutoSwarmHelper.sol";

import {console} from "forge-std/console.sol";

contract SetUpAutoSwarmHelper is SetUpSwarm, SetUpERC6551, SetUpAutoSwarmAccount {
    AutoSwarmHelper public autoSwarmHelper;
    bytes32 batchId1;
    uint256 ttl1 = 10 weeks;
    uint8 depth1 = 20;

    function setUpAutoSwarmHelper() public {
        console.log(msg.sender, "setUpAutoSwarm msg.sender");
        console.log(address(this), "setUpAutoSwarm address(this)");

        autoSwarmHelper = AutoSwarmHelper((deploy("AutoSwarmHelper")));
    }

    function setUp() public {
        setUpERC6551();
        setUpSwarm();
        setUpAutoSwarmAccount();
        setUpAutoSwarmHelper();
    }
}
