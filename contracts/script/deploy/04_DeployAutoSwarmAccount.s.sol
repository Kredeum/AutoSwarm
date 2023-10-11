// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DeployLite} from "@forge-deploy-lite/DeployLite.s.sol";
import {AutoSwarmAccount} from "@autoswarm/src/AutoSwarmAccount.sol";

contract DeployAutoSwarmAccount is DeployLite {
    function deployAutoSwarmAccount() public returns (address autoSwarmAccountAddress) {
        address postageStamp = deploy("PostageStamp", false);

        vm.startBroadcast(deployer);
        AutoSwarmAccount autoSwarmAccount = new AutoSwarmAccount();
        // autoSwarmAccount.initialize(payable(postageStamp));
        vm.stopBroadcast();

        autoSwarmAccountAddress = address(autoSwarmAccount);
    }

    function run() public virtual {
        deploy("AutoSwarmAccount");
    }
}
