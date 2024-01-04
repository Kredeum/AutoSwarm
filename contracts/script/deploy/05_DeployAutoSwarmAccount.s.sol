// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {DeployLite} from "@forge-deploy-lite/DeployLite.s.sol";
import {AutoSwarmAccount} from "@autoswarm/src/AutoSwarmAccount.sol";
import {AutoSwarmMarket} from "@autoswarm/src/AutoSwarmMarket.sol";

contract DeployAutoSwarmAccount is DeployLite {
    function deployAutoSwarmAccount() public returns (address autoSwarmAccount) {
        address autoSwarmMarket = deploy("AutoSwarmMarket");

        vm.startBroadcast(deployer);
        autoSwarmAccount = address(new AutoSwarmAccount(autoSwarmMarket));
        vm.stopBroadcast();
    }

    function run() public virtual {
        deploy("AutoSwarmAccount");
    }
}
