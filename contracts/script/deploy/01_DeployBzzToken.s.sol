// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {DeployLite} from "@forge-deploy-lite/DeployLite.s.sol";

import {BzzToken} from "@autoswarm/src/mocks/BzzToken.sol";

contract DeployBzzToken is DeployLite {
    function deployBzzToken() public returns (address bzzToken) {
        DeployState state = deployState("BzzToken");

        if (state == DeployState.None) {
            vm.startBroadcast();

            bzzToken = deploy("BzzToken");
            BzzToken(bzzToken).mint(msg.sender, 10 ^ 9);

            vm.stopBroadcast();
        }
    }

    function run() public virtual {
        deployBzzToken();
    }
}
