// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import "./SetUpAutoSwarm.t.sol";

contract SetUpAutoSwarmTest is SetUpAutoSwarm {
    function test_SetUpAutoSwarm_OK() public pure {
        assert(true);
    }

    function test_SetUpAutoSwarm_AutoSwarm() public view {
        (,, bytes memory codeToDeploy) = isDeployed("AutoSwarm");
        require(isSameRunCode(codeToDeploy, address(autoSwarm).code), "AutoSwarm code differs");
    }
}
