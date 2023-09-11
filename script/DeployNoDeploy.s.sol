// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DeployLite} from "lib/forge-deploy-lite/script/DeployLite.s.sol";

contract DeployNoDeploy is DeployLite {
    function deployNoDeploy() public returns (address) {
        vm.startBroadcast(deployer);
        logCallers("deployNoDeploy callers");
        vm.stopBroadcast();

        return address(0);
    }

    function run() public virtual {
        logCallers("DeployAll callers");
        deploy("NoDeploy");
    }
}
