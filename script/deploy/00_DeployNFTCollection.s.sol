// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DeployLite} from "lib/forge-deploy-lite/script/DeployLite.s.sol";
import {NFTCollection} from "src/NFTCollection.sol";
import {console} from "forge-std/console.sol";

contract DeployNFTCollection is DeployLite {
    function deployNFTCollection() public returns (address collection) {
        vm.startBroadcast(deployer);
        collection = address(new NFTCollection());
        NFTCollection(collection).mint(deployer);
        vm.stopBroadcast();
    }

    function run() public virtual {
        deploy("NFTCollection");
    }
}
