// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DeployLite} from "lib/forge-deploy-lite/script/DeployLite.s.sol";
import {AutoSwarmAccount} from "src/AutoSwarmAccount.sol";

contract DeployAutoSwarmAccount is DeployLite {
    function deployAutoSwarmAccount() public returns (address autoSwarmAccount) {
        address postageStamp = deploy("PostageStamp", false);

        vm.startBroadcast(deployer);
        autoSwarmAccount = address(new AutoSwarmAccount( payable(postageStamp)));
        vm.stopBroadcast();
    }

    function run() public virtual {
        deploy("AutoSwarmAccount");
    }
}
