// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import "@autoswarm/test/SetUpAutoSwarmAccount.t.sol";

contract SetUpAutoSwarmAccountTest is SetUpAutoSwarmAccount {
    function test_SetUpAutoSwarmAccount_OK() public pure {
        assert(true);
    }

    function test_SetUpAutoSwarmAccount_AutoSwarmAccount() public view {
        bytes memory codeToDeploy = getCodeToDeploy("AutoSwarmAccount");
        require(isSameRunCode(address(implementation).code, codeToDeploy), "AutoSwarmAccount code differs");
    }
}
