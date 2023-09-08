// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {DeployLite} from "lib/forge-deploy-lite/script/DeployLite.sol";
import {SimpleERC6551Account} from "lib/erc6551/src/examples/simple/SimpleERC6551Account.sol";
import {ERC6551Registry} from "lib/erc6551/src/ERC6551Registry.sol";
import {IERC721Enumerable} from "lib/forge-std/src/interfaces/IERC721.sol";
import {ERC721PresetMinterPauserAutoId} from
    "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";

contract SetUpERC6551 is Test, DeployLite {
    uint256 salt = 0;

    uint256 chainId;
    address collection;
    uint256 tokenId;

    ERC6551Registry registry;
    SimpleERC6551Account implementation;

    function setUpERC6551() public {
        chainId = block.chainid;
        tokenId = 1;

        collection = readAddress("NFTCollection");
        if (collection.code.length == 0) {
            collection = address(new ERC721PresetMinterPauserAutoId("NFT Test", "NFTT", "/"));
            ERC721PresetMinterPauserAutoId(collection).mint(msg.sender);
            console.log(collection, "ERC721 collection newly deployed and minted once");
        }

        registry = ERC6551Registry(readAddress("ERC6551Registry"));
        if (address(registry).code.length == 0) {
            registry = new ERC6551Registry();
            console.log(address(registry), "ERC6551Registry newly deployed");
        }

        implementation = SimpleERC6551Account(payable(readAddress("SimpleERC6551Account")));
        if (address(implementation).code.length == 0) {
            implementation = new SimpleERC6551Account();
            console.log(address(implementation), "SimpleERC6551Account newly deployed");
        }
    }
}
