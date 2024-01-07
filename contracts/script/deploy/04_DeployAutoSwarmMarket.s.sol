// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {DeployLite} from "@forge-deploy-lite/DeployLite.s.sol";
import {AutoSwarmAccount} from "@autoswarm/src/AutoSwarmAccount.sol";
import {AutoSwarmMarket} from "@autoswarm/src/AutoSwarmMarket.sol";

// import {console} from "forge-std/console.sol";

contract DeployAutoSwarmMarket is DeployLite {
    function deployAutoSwarmMarket() public returns (address) {
        address postageStamp = readAddress("PostageStamp");
        address swarmNode = readAddress("SwarmNode");
        address autoSwarmAccount = readAddress("AutoSwarmAccount");

        (address autoSwarmMarket, DeployedState state) = deploy("AutoSwarmMarket", abi.encode(postageStamp, swarmNode));

        // if (state == DeployedState.Newly) {
        //     vm.startBroadcast();

        //     if (autoSwarmAccount.code.length > 0) {
        //         AutoSwarmAccount(payable(autoSwarmAccount)).setAutoSwarmMarket(autoSwarmMarket);
        //     }
        //     vm.stopBroadcast();
        // }

        return autoSwarmMarket;
    }

    function run() public virtual {
        deployAutoSwarmMarket();
    }
}
