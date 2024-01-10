// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {DeployLite} from "@forge-deploy-lite/DeployLite.s.sol";

contract DeployERC6551Registry is DeployLite {
    function deployERC6551Registry() public returns (address) {
        DeployState state = deployState("ERC6551Registry");

        if (state == DeployState.None) {
            vm.broadcast();
            deploy("ERC6551Registry");
        }

        return readAddress("ERC6551Registry");
    }

    function run() public virtual {
        deployERC6551Registry();
    }
}
