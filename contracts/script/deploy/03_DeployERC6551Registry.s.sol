// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {DeployLite} from "@forge-deploy-lite/DeployLite.s.sol";
import {ERC6551Registry} from "@erc6551/ERC6551Registry.sol";

contract DeployERC6551Registry is DeployLite {
    function deployERC6551Registry() public returns (address erc6551Registry) {
        DeployState state = deployState("ERC6551Registry");

        if (state == DeployState.None) {
            vm.broadcast();
            erc6551Registry = deploy("ERC6551Registry");
        }
    }

    function run() public virtual {
        deployERC6551Registry();
    }
}
