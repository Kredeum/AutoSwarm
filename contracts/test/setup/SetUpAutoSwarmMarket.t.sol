// SPDX-License-Identifier: MITs
pragma solidity ^0.8.4;

import {AutoSwarmMarket} from "@autoswarm/src/AutoSwarmMarket.sol";
import {SetUpSwarm} from "@autoswarm/test/setup/SetUpSwarm.t.sol";

contract SetUpAutoSwarmMarket is SetUpSwarm {
    AutoSwarmMarket public autoSwarmMarket;

    uint8 internal constant _INITIAL_DEPTH = 23;
    uint256 internal constant _INITIAL_TTL = 30 days;
    uint256 internal _DEFAULT_PRICE = 24_000;

    function setUpAutoSwarmMarket() public {
        autoSwarmMarket = AutoSwarmMarket(deploy("AutoSwarmMarket"));

        deal(address(bzzToken), address(autoSwarmMarket), (_INITIAL_TTL * _DEFAULT_PRICE) << _INITIAL_DEPTH);

        vm.prank(deployer);
        autoSwarmMarket.newBatch();
    }

    function setUp() public virtual {
        setRecording(false);
        setUpSwarm();
        setUpAutoSwarmMarket();
    }
}
