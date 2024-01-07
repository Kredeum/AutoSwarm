// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {DeployLite} from "@forge-deploy-lite/DeployLite.s.sol";

import {BzzToken} from "@autoswarm/src/mocks/BzzToken.sol";

contract DeployBzzToken is DeployLite {
    function deployBzzToken() public returns (address){
        (address bzzToken, DeployedState state) = deploy("BzzToken", "", false);

        if (state == DeployedState.Newly) {
            vm.startBroadcast();
            BzzToken(bzzToken).mint(msg.sender, 10 ^ 9);
            vm.stopBroadcast();
        }

        return bzzToken;
    }

    function run() public virtual {
        deployBzzToken();
    }
}
