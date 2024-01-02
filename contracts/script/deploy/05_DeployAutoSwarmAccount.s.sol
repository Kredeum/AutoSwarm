// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {DeployLite} from "@forge-deploy-lite/DeployLite.s.sol";
import {AutoSwarmAccount} from "@autoswarm/src/AutoSwarmAccount.sol";
import {AutoSwarmMarket} from "@autoswarm/src/AutoSwarmMarket.sol";

contract DeployAutoSwarmAccount is DeployLite {
    function deployAutoSwarmAccount() public returns (address autoSwarmAccountAddress) {
        AutoSwarmMarket autoSwarmMarket = AutoSwarmMarket(deploy("AutoSwarmMarket"));

        vm.startBroadcast(deployer);
        AutoSwarmAccount autoSwarmAccount = new AutoSwarmAccount(autoSwarmMarket);
        vm.stopBroadcast();

        autoSwarmAccountAddress = address(autoSwarmAccount);
    }

    function run() public virtual {
        deploy("AutoSwarmAccount");
    }
}
