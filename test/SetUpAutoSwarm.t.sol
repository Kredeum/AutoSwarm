// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {AutoSwarm} from "src/AutoSwarm.sol";

import {SetUpSwarm} from "./SetUpSwarm.t.sol";
import {SetUpERC6551} from "./SetUpERC6551.t.sol";

contract SetUpAutoSwarm is SetUpSwarm, SetUpERC6551 {
    AutoSwarm public autoSwarm;

    function setUpAutoSwarm() public {
        autoSwarm = AutoSwarm(deployAutoSwarm());
    }

    function setUp() public {
        setUpERC6551();
        setUpSwarm();
        setUpAutoSwarm();
        setUpSwarmBatchId(address(autoSwarm));
    }
}
