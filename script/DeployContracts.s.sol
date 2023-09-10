// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DeployLite} from "lib/forge-deploy-lite/script/DeployLite.s.sol";
import {NewContracts} from "src/lib/NewContracts.sol";

contract DeployContracts is DeployLite, NewContracts {
    function deployBzzToken() public returns (address bzzToken) {
        vm.startBroadcast();
        bzzToken = address(newBzzToken());
        vm.stopBroadcast();
    }

    function deployNFTCollection() public returns (address collection) {
        vm.startBroadcast();
        collection = address(newNFTCollection());
        vm.stopBroadcast();
    }

    function deployERC6551Registry() public returns (address erc6551Registry) {
        vm.startBroadcast();
        erc6551Registry = address(newERC6551Registry());
        vm.stopBroadcast();
    }

    function deploySimpleERC6551Account() public returns (address simpleERC6551Account) {
        vm.startBroadcast();
        simpleERC6551Account = address(newSimpleERC6551Account());
        vm.stopBroadcast();
    }

    function deployPostageStamp() public returns (address postageStamp) {
        address bzzToken = deploy("BzzToken");
        address admin = getAddress("Admin");

        vm.startBroadcast();
        postageStamp = address(newPostageStamp(bzzToken, admin));
        vm.stopBroadcast();
    }

    function deployAutoSwarm() public returns (address autoSwarm) {
        address registry = deploy("ERC6551Registry");
        address implementation = deploy("SimpleERC6551Account");
        address postageStamp = deploy("PostageStamp");

        vm.startBroadcast();
        autoSwarm = address(newAutoSwarm(registry, implementation, postageStamp));
        vm.stopBroadcast();
    }
}
