// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {DeployLite} from "@forge-deploy-lite/DeployLite.s.sol";
import {NFTCollection} from "@autoswarm/src/mocks/NFTCollection.sol";

// import {console} from "forge-std/console.sol";

contract DeployNFTCollection is DeployLite {
    function deployNFTCollection() public returns (address) {
        DeployState state = deployState("NFTCollection");

        if (state == DeployState.None) {
            vm.startBroadcast();

            address nftCollection = deploy("NFTCollection");
            NFTCollection(nftCollection).mint(msg.sender);

            vm.stopBroadcast();
        }

        return readAddress("NFTCollection");
    }

    function run() public virtual {
        deployNFTCollection();
    }
}
