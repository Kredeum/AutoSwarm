// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {DeployLite} from "@forge-deploy-lite/DeployLite.s.sol";
import {PostageStamp} from "storage-incentives/PostageStamp.sol";

contract DeployPostageStamp is DeployLite {
    function deployPostageStamp() public returns (address postageStampAddress) {
        address bzzToken = deploy("BzzToken", false);

        vm.startBroadcast(deployer);
        PostageStamp postageStamp = new PostageStamp(bzzToken, 16);
        postageStamp.grantRole(postageStamp.PRICE_ORACLE_ROLE(), deployer);
        postageStamp.setPrice(24000);
        vm.stopBroadcast();

        postageStampAddress = address(postageStamp);
    }

    function run() public virtual {
        deploy("PostageStamp");
    }
}
