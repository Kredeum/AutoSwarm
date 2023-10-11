// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DeployLite} from "@forge-deploy-lite/DeployLite.s.sol";
import {AutoSwarmHelper} from "@autoswarm/src/AutoSwarmHelper.sol";

contract DeployAutoSwarmHelper is DeployLite {
    function deployAutoSwarmHelper() public returns (address autoSwarmHelperAddress) {
        address postageStamp = deploy("PostageStamp");
        address erc6551Registry = deploy("ERC6551Registry");
        address autoSwarmAccount = deploy("AutoSwarmAccount");
        AutoSwarmHelper.Config memory config =
            AutoSwarmHelper.Config(msg.sender, erc6551Registry, autoSwarmAccount, postageStamp);

        vm.startBroadcast(deployer);
        AutoSwarmHelper autoSwarmHelper = new AutoSwarmHelper();
        // autoSwarmHelper.setConfig(config);
        vm.stopBroadcast();

        autoSwarmHelperAddress = address(autoSwarmHelper);
    }

    function run() public virtual {
        deploy("AutoSwarmHelper");
    }
}
