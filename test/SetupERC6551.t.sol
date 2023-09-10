// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {DeployLite} from "lib/forge-deploy-lite/script/DeployLite.s.sol";
import {SimpleERC6551Account} from "lib/erc6551/src/examples/simple/SimpleERC6551Account.sol";
import {ERC6551Registry} from "lib/erc6551/src/ERC6551Registry.sol";

import {DeployAll} from "script/DeployAll.s.sol";
import {NewContracts} from "src/lib/NewContracts.sol";

contract SetUpERC6551 is Test, DeployAll {
    uint256 salt = 0;

    uint256 chainId;
    address collection;
    uint256 tokenId;

    ERC6551Registry registry;
    SimpleERC6551Account implementation;

    function setUpERC6551() public {
        console.log(msg.sender, "SetUpERC6551 msg.sender");
        console.log(address(this), "SetUpERC6551 this");

        chainId = block.chainid;
        tokenId = 1;

        collection = deploy("NFTCollection");
        registry = ERC6551Registry(deploy("ERC6551Registry"));
        implementation = SimpleERC6551Account(payable(deploy("SimpleERC6551Account")));
    }
}
