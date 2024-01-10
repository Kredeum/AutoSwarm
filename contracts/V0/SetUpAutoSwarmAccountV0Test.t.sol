// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import "@autoswarm/test/v0/SetUpAutoSwarmAccountV0.t.sol";

contract SetUpAutoSwarmAccountV0Test is SetUpAutoSwarmAccountV0 {
    function test_SetUpAutoSwarmAccountV0_OK() public pure {
        assert(true);
    }

    function test_SetUpAutoSwarmAccountV0_AutoSwarmAccountV0() public view {
        bytes memory codeToDeploy = _getCodeToDeploy("AutoSwarmAccountV0");
        require(_isSameCode(address(implementation).code, codeToDeploy), "AutoSwarmAccountV0 code differs");
    }
}
