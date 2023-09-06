// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {ReadWriteJson} from "lib/forge-deploy-lite/script/ReadWriteJson.sol";
import {SimpleERC6551Account} from "lib/erc6551/src/examples/simple/SimpleERC6551Account.sol";
import {ERC6551Registry} from "lib/erc6551/src/ERC6551Registry.sol";
import {IERC721Enumerable} from "lib/forge-std/src/interfaces/IERC721.sol";

contract SetupERC6551Test is Test, ReadWriteJson {
    uint256 salt = 0;

    uint256 chainId;
    address collection;
    uint256 tokenId;

    address registry;
    address implementation;

    function setUp() public {
        chainId = block.chainid;
        tokenId = 1;

        collection = readAddress("NFTCollection");
        if (address(collection).code.length == 0) {
            // collection = new Collection();
        }

        registry = readAddress("ERC6551Registry");
        if (address(registry).code.length == 0) {
            // registry = new ERC6551Registry();
        }

        implementation = readAddress("SimpleERC6551Account");
        if (address(implementation).code.length == 0) {
            // implementation = new Implementation();
        }
    }
}
