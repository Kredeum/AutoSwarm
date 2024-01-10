// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {DeployLite} from "@forge-deploy-lite/DeployLite.s.sol";
import {AutoSwarmMarket} from "@autoswarm/src/AutoSwarmMarket.sol";
import {AutoSwarmAccount} from "@autoswarm/src/AutoSwarmAccount.sol";
import {DeployAutoSwarmMarket} from "./04_DeployAutoSwarmMarket.s.sol";

// import {console} from "forge-std/console.sol";

contract DeployAutoSwarmAccount is DeployLite, DeployAutoSwarmMarket {
    function deployAutoSwarmAccount() public returns (address autoSwarmAccount) {
        address autoSwarmMarket = deployAutoSwarmMarket();

        bytes memory args = abi.encode(autoSwarmMarket);
        DeployState state = deployState("AutoSwarmAccount", args);

        if (state == DeployState.None || state == DeployState.Older) {
            vm.broadcast();
            deploy("AutoSwarmAccount", abi.encode(autoSwarmMarket));
        } else {
            AutoSwarmAccount implementation = AutoSwarmAccount(payable(readAddress("AutoSwarmAccount")));
            if (implementation.getAutoSwarmMarket() != autoSwarmMarket) {
                vm.broadcast();
                implementation.setAutoSwarmMarket(autoSwarmMarket);
            }
        }

        return readAddress("AutoSwarmAccount");
    }

    function run() public virtual override(DeployAutoSwarmMarket) {
        deployAutoSwarmAccount();
    }
}
