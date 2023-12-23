// SPDX-License-Identifier: MITs
pragma solidity ^0.8.4;

import "@autoswarm/test/setup/SetUpAutoSwarmAccount.t.sol";

contract SetUpAutoSwarmAccountTest is SetUpAutoSwarmAccount {
    function test_SetUpAutoSwarmAccount_OK() public pure {
        assert(true);
    }

    function test_SetUpAutoSwarmAccount_newBatch() public {
        deal(address(bzzToken), address(autoSwarmMarket), (_INITIAL_TTL * _DEFAULT_PRICE) << _INITIAL_DEPTH);

        autoSwarmMarket.newBatch(swarmNode);
        assert(true);
    }

    function test_SetUpAutoSwarmAccount_AutoSwarmAccount() public view {
        bytes memory codeToDeploy = getCodeToDeploy("AutoSwarmAccount");
        require(isSameRunCode(address(implementation).code, codeToDeploy), "AutoSwarmAccount code differs");
    }
}
