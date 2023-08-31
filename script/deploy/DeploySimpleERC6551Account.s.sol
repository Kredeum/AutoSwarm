// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {DeployLite} from "lib/forge-deploy-lite/script/DeployLite.sol";
import {SimpleERC6551Account} from "lib/erc6551/src/examples/simple/SimpleERC6551Account.sol";

contract DeploySimpleERC6551Account is DeployLite {
    function deploySimpleERC6551Account() public returns (address simpleERC6551Account) {
        vm.startBroadcast();

        simpleERC6551Account = address(new SimpleERC6551Account());

        vm.stopBroadcast();
    }

    function run() public virtual {
        deploy("SimpleERC6551Account");
    }
}
