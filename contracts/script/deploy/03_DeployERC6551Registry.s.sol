// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {DeployLite} from "@forge-deploy-lite/DeployLite.s.sol";
import {ERC6551Registry} from "@erc6551/ERC6551Registry.sol";

contract DeployERC6551Registry is DeployLite {
    function deployERC6551Registry() public returns (address erc6551Registry) {
        vm.startBroadcast(deployer);
        erc6551Registry = address(new ERC6551Registry());
        vm.stopBroadcast();
    }

    function run() public virtual {
        deploy("ERC6551Registry");
    }
}
