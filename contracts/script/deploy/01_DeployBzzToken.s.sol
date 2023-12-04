// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {DeployLite} from "@forge-deploy-lite/DeployLite.s.sol";

import {BzzToken} from "@autoswarm/src/mocks/BzzToken.sol";

contract DeployBzzToken is DeployLite {
    function deployBzzToken() public returns (address bzzToken) {
        vm.startBroadcast(deployer);
        bzzToken = address(new BzzToken());
        BzzToken(bzzToken).mint(deployer, 10 ^ 9);
        vm.stopBroadcast();
    }

    function run() public virtual {
        deploy("BzzToken");
    }
}
