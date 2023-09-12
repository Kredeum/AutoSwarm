// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {AutoSwarmAccount} from "src/AutoSwarmAccount.sol";

import {SetUpSwarm} from "./SetUpSwarm.t.sol";
import {SetUpERC6551} from "./SetUpERC6551.t.sol";

contract SetUpAutoSwarmAccount is SetUpSwarm, SetUpERC6551 {
    AutoSwarmAccount public autoSwarmAccount;
    bytes32 batchId0;
    uint256 ttl0 = 10 weeks;
    uint8 depth0 = 20;

    function setUpAutoSwarmAccount() public {
        autoSwarmAccount = AutoSwarmAccount(payable(deploy("AutoSwarmAccount")));

        deal(address(bzzToken), address(autoSwarmAccount), ttl0 << depth0);
        batchId0 = autoSwarmAccount.stampsBuy(ttl0, depth0);
    }

    function setUp() public {
        setUpERC6551();
        setUpSwarm();
        setUpAutoSwarmAccount();
    }
}
