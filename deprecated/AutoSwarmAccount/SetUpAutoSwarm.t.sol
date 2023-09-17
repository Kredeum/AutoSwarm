// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {AutoSwarmAccount} from "src/AutoSwarmAccount.sol";

import {SetUpSwarm} from "./SetUpSwarm.t.sol";
import {SetUpERC6551} from "./SetUpERC6551.t.sol";
import {AutoSwarm} from "src/AutoSwarm.sol";

contract SetUpAutoSwarm is SetUpSwarm, SetUpERC6551 {
    AutoSwarm public autoSwarm;
    bytes32 batchId1;
    uint256 ttl1 = 10 weeks;
    uint8 depth1 = 20;

    function setUpAutoSwarm() public {
        autoSwarm = AutoSwarm(payable(deploy("AutoSwarm")));

        // deal(address(bzzToken), address(autoSwarm), ttl1 << depth1);
        // batchId0 = autoSwarm.stampsBuy(chainId, collection, tokenId, ttl1, depth1);
    }

    function setUp() public {
        setUpERC6551();
        setUpSwarm();
        setUpAutoSwarm();
    }
}
