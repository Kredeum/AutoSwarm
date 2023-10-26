// SPDX-License-Identifier: MITs
pragma solidity ^0.8.4;

import {AutoSwarmMarket} from "@autoswarm/src/AutoSwarmMarket.sol";
import {SetUpSwarm} from "@autoswarm/test/SetUpSwarm.t.sol";

contract SetUpAutoSwarmMarket is SetUpSwarm {
    AutoSwarmMarket public autoSwarmMarket;
    // uint256 initYear;
    // uint256 initTtl;
    // uint8 initDepth;

    function setUpAutoSwarmMarket() public {
        autoSwarmMarket = AutoSwarmMarket(deploy("AutoSwarmMarket"));

        // initYear = autoSwarmMarket.FIRST_YEAR();
        // initTtl = autoSwarmMarket.INITIAL_TTL();
        // initDepth = autoSwarmMarket.INITIAL_DEPTH();

        // uint256 amount = initTtl << initDepth;

        // deal(address(bzzToken), address(autoSwarmMarket), amount);

        // vm.prank(deployer);
        // autoSwarmMarket.buyBatch(initYear);
    }

    function setUp() public virtual {
        setRecording(false);
        setUpSwarm();
        setUpAutoSwarmMarket();
    }
}
