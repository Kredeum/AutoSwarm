// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DeployLite} from "lib/forge-deploy-lite/script/DeployLite.s.sol";
import {BzzToken} from "src/BzzToken.sol";

contract DeployBzzToken is DeployLite {
    function deployBzzToken() public returns (address bzzToken) {
        vm.startBroadcast(deployer);
        bzzToken = address(new BzzToken());
        BzzToken(bzzToken).mint(deployer, 10 ^ 20);
        vm.stopBroadcast();
    }

    function run() public virtual {
        deploy("BzzToken");
    }
}
