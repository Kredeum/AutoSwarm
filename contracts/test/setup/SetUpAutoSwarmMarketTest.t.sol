// SPDX-License-Identifier: MITs
pragma solidity 0.8.23;

import "@autoswarm/test/setup/SetUpAutoSwarmMarket.t.sol";

contract SetUpAutoSwarmMarketTest is SetUpAutoSwarmMarket {
    function test_SetUpAutoSwarmMarket_OK() public pure {
        assert(true);
    }

    function test_SetUpAutoSwarmMarket_AutoSwarmMarket() public view {
        bytes memory codeToDeploy = _getCodeToDeploy("AutoSwarmMarket");
        require(_isSameCode(address(autoSwarmMarket).code, codeToDeploy), "AutoSwarmMarket code differs");
    }
}
