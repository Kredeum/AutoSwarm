// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {DeployLite} from "@forge-deploy-lite/DeployLite.s.sol";
import {DeployPostageStamp} from "./02_DeployPostageStamp.s.sol";

import {console} from "forge-std/console.sol";

contract DeployAutoSwarmMarket is DeployLite, DeployPostageStamp {
    function deployAutoSwarmMarket() public returns (address) {
        address postageStamp = deployPostageStamp();
        address swarmNode = readAddress("SwarmNode");

        bytes memory args = abi.encode(postageStamp, swarmNode);
        DeployState state = deployState("AutoSwarmMarket", args);

        if (state == DeployState.None || state == DeployState.Older) {
            vm.broadcast();
            deploy("AutoSwarmMarket", args);
        }

        return readAddress("AutoSwarmMarket");
    }

    function run() public virtual override(DeployPostageStamp) {
        deployAutoSwarmMarket();
    }
}
