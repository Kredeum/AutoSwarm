// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DeployLite} from "lib/forge-deploy-lite/script/DeployLite.s.sol";
import {AutoSwarmAccount} from "src/AutoSwarmAccount.sol";

contract DeployAutoSwarmAccount is DeployLite {
    function deployAutoSwarmAccount() public returns (address autoSwarmAccountAddress) {
        address postageStamp = deploy("PostageStamp", false);

        vm.startBroadcast(deployer);
        AutoSwarmAccount autoSwarmAccount = new AutoSwarmAccount();
        autoSwarmAccount.initialize(payable(postageStamp));
        vm.stopBroadcast();

        autoSwarmAccountAddress = address(autoSwarmAccount);
    }

    function run() public virtual {
        deploy("AutoSwarmAccount");
    }
}
