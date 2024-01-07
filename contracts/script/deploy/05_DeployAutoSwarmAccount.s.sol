// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {DeployLite} from "@forge-deploy-lite/DeployLite.s.sol";
import {AutoSwarmAccount} from "@autoswarm/src/AutoSwarmAccount.sol";
import {AutoSwarmMarket} from "@autoswarm/src/AutoSwarmMarket.sol";

contract DeployAutoSwarmAccount is DeployLite {
    function deployAutoSwarmAccount() public returns (address autoSwarmAccount) {
        address autoSwarmMarket = readAddress("AutoSwarmMarket");

        (autoSwarmAccount,) = deploy("AutoSwarmAccount", abi.encode(autoSwarmMarket), false);
    }

    function run() public virtual {
        deployAutoSwarmAccount();
    }
}
