// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {SimpleERC6551Account} from "@erc6551/examples/simple/SimpleERC6551Account.sol";
import {IAutoSwarmAccount} from "./interfaces/IAutoSwarmAccount.sol";

import {console} from "forge-std/console.sol";

contract AutoSwarmAccount is IAutoSwarmAccount, SimpleERC6551Account {
    function isOwner() external view returns (bool ok) {
        ok = owner() == msg.sender;
    }
}
