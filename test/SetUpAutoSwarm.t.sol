// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {AutoSwarm} from "src/AutoSwarm.sol";

import "./SetUpSwarm.t.sol";
import "./SetUpERC6551.t.sol";

contract SetUpAutoSwarm is SetUpSwarm, SetUpERC6551 {
    AutoSwarm public autoSwarm;

    function setUpAutoSwarm() public {
        autoSwarm = AutoSwarm(readAddress("AutoSwarm"));
        if (address(autoSwarm).code.length == 0) {
            autoSwarm = new AutoSwarm(address(registry),payable(address(implementation)),payable(address(postageStamp)));
            console.log(address(autoSwarm), "AutoSwarm newly deployed");
        }
    }

    function setUp() public {
        setUpERC6551();
        setUpSwarm();
        setUpAutoSwarm();
        setUpSwarmBatchId(address(autoSwarm));
    }
}
