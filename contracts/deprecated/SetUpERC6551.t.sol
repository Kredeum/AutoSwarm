// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {ERC6551Registry} from "lib/erc6551/src/ERC6551Registry.sol";
import {SimpleERC6551Account} from "lib/erc6551/src/examples/simple/SimpleERC6551Account.sol";

import {DeployAll} from "script/DeployAll.s.sol";

contract SetUpERC6551 is Test, DeployAll {
    uint256 salt = 0;

    uint256 chainId;
    address collection;
    uint256 tokenId;

    ERC6551Registry registry;
    SimpleERC6551Account implementation;

    function setUpERC6551() public {
        log3(msg.sender, "MsgSender", "SetUpERC6551");
        log3(address(this), "This", "SetUpERC6551");

        chainId = block.chainid;
        tokenId = 0;

        setDeployer(makeAddr("NFTOwner"));
        collection = deploy("NFTCollection");

        setDeployer(makeAddr("Deployer"));
        registry = ERC6551Registry(deploy("ERC6551Registry"));
        implementation = SimpleERC6551Account(payable(deploy("SimpleERC6551Account")));
    }
}
