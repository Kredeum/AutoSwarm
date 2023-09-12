// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import "./SetUpAutoSwarmAccount.t.sol";

contract SetUpAutoSwarmAccountTest is SetUpAutoSwarmAccount {
    function test_SetUpAutoSwarmAccount_OK() public pure {
        assert(true);
    }

    function test_SetUpAutoSwarmAccount_AutoSwarmAccount() public view {
        bytes memory codeToDeploy = getCodeToDeploy("AutoSwarmAccount");
        require(isSameRunCode(codeToDeploy, address(autoSwarmAccount).code), "AutoSwarmAccount code differs");
    }
}
