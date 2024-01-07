// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {console} from "forge-std/console.sol";
import {DeployLite} from "@forge-deploy-lite/DeployLite.s.sol";

import {NFTCollection} from "@autoswarm/src/mocks/NFTCollection.sol";

contract DeployNFTCollection is DeployLite {
    function deployNFTCollection() public returns(address) {
        (address nftCollection, DeployedState state) = deploy("NFTCollection", "", false);

        if (state == DeployedState.Newly) {
            vm.startBroadcast();
            NFTCollection(nftCollection).mint(msg.sender);
            vm.stopBroadcast();
        }

        return nftCollection;
    }

    function run() public virtual {
        deployNFTCollection();
    }
}
