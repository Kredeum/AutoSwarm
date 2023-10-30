// SPDX-License-Identifier: MITs
pragma solidity ^0.8.4;

import {IERC721} from "forge-std/interfaces/IERC721.sol";
import {console} from "forge-std/console.sol";
import {Test, console} from "forge-std/Test.sol";
import {ERC6551Registry} from "@erc6551/ERC6551Registry.sol";

import {AutoSwarmAccount} from "@autoswarm/src/AutoSwarmAccount.sol";
import {DeployAll} from "@autoswarm/script/DeployAll.s.sol";

contract SetUpERC6551 is Test, DeployAll {
    bytes32 public salt = keccak256("AutoSwarm V0.2");

    uint256 chainId;
    address collection;
    uint256 tokenId;
    address nftOwner;

    ERC6551Registry registry;
    AutoSwarmAccount implementation;

    function setUpERC6551() public {
        log3(msg.sender, "MsgSender", "SetUpERC6551");
        log3(address(this), "This", "SetUpERC6551");

        chainId = block.chainid;
        tokenId = 0;

        setDeployer(makeAddr("NFTOwner"));
        collection = deploy("NFTCollection");
        nftOwner = IERC721(collection).ownerOf(tokenId);
        require(nftOwner != address(0), "NFT not exists or burned");

        setDeployer(makeAddr("Deployer"));
        registry = ERC6551Registry(deploy("ERC6551Registry"));

        implementation = AutoSwarmAccount(payable(deploy("AutoSwarmAccount")));
    }
}
