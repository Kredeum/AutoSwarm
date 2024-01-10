// SPDX-License-Identifier: MITs
pragma solidity 0.8.23;

import "@autoswarm/test/setup/SetUpAutoSwarmAccount.t.sol";

contract SetUpAutoSwarmAccountTest is SetUpAutoSwarmAccount {
    function test_SetUpAutoSwarmAccount_OK() public pure {
        assert(true);
    }

    function test_SetUpAutoSwarmAccount_AutoSwarmAccount() public view {
        bytes memory codeToDeploy = _getCodeToDeploy("AutoSwarmAccount");
        require(_isSameCode(address(implementation).code, codeToDeploy), "AutoSwarmAccount code differs");
    }
}
