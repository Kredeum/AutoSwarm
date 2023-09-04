// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

import {DeployLite} from "lib/forge-deploy-lite/script/DeployLite.sol";
import {ERC6551Registry} from "lib/erc6551/src/ERC6551Registry.sol";

contract DeployERC6551Registry is DeployLite {
    function deployERC6551Registry() public returns (address erc6551Registry) {
        vm.startBroadcast();

        erc6551Registry = address(new ERC6551Registry());

        vm.stopBroadcast();
    }

    function run() public virtual {
        deploy("ERC6551Registry");
    }
}
