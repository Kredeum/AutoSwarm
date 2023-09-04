// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DeployERC6551Registry} from "script/deploy/DeployERC6551Registry.s.sol";
import {DeploySimpleERC6551Account} from "script/deploy/DeploySimpleERC6551Account.s.sol";

contract DeployAll is DeployERC6551Registry, DeploySimpleERC6551Account {
    function run() public override(DeployERC6551Registry, DeploySimpleERC6551Account) {
        deploy("ERC6551Registry");
        deploy("SimpleERC6551Account");
    }
}
