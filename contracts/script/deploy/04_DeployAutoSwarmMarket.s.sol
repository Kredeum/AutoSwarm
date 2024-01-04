// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {DeployLite} from "@forge-deploy-lite/DeployLite.s.sol";
import {AutoSwarmAccount} from "@autoswarm/src/AutoSwarmAccount.sol";
import {AutoSwarmMarket} from "@autoswarm/src/AutoSwarmMarket.sol";

import {console} from "forge-std/console.sol";

contract DeployAutoSwarmMarket is DeployLite {
    function deployAutoSwarmMarket() public returns (address autoSwarmMarket) {
        address postageStamp = deploy("PostageStamp", false);
        address swarmNode = readAddress("SwarmNode");
        address autoSwarmAccount = readAddress("AutoSwarmAccount");

        vm.startBroadcast(deployer);
        autoSwarmMarket = address(new AutoSwarmMarket(postageStamp, swarmNode));

        if (autoSwarmAccount.code.length > 0) {
            AutoSwarmAccount(payable(autoSwarmAccount)).setAutoSwarmMarket(autoSwarmMarket);
        }
        vm.stopBroadcast();
    }

    function run() public virtual {
        deploy("AutoSwarmMarket");
    }
}
