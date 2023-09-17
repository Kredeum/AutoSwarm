// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {ERC6551Registry} from "lib/erc6551/src/ERC6551Registry.sol";
import {AutoSwarmAccount} from "src/AutoSwarmAccount.sol";
import {IERC721} from "forge-std/interfaces/IERC721.sol";
import {console} from "forge-std/console.sol";

import {DeployAll} from "script/DeployAll.s.sol";

contract SetUpERC6551 is Test, DeployAll {
    uint256 public salt = uint256(keccak256("AutoSwarm V0"));

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
