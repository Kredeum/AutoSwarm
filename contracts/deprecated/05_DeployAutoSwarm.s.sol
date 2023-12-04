// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DeployLite} from "lib/forge-deploy-lite/script/DeployLite.s.sol";
import {AutoSwarm} from "src/AutoSwarm.sol";

contract DeployAutoSwarm is DeployLite {
    function deployAutoSwarm() public returns (address autoSwarm) {
        address registry = deploy("ERC6551Registry");
        address implementation = deploy("SimpleERC6551Account");
        address postageStamp = deploy("PostageStamp");

        vm.startBroadcast(deployer);
        autoSwarm = address(new AutoSwarm(registry, payable(implementation), payable(postageStamp)));
        vm.stopBroadcast();
    }

    function run() public virtual {
        deploy("AutoSwarm");
    }
}
