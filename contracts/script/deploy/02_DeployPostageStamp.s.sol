// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {DeployLite} from "@forge-deploy-lite/DeployLite.s.sol";
import {PostageStamp} from "storage-incentives/PostageStamp.sol";

contract DeployPostageStamp is DeployLite {
    function deployPostageStamp() public returns (address postageStamp) {
        address bzzToken = deploy("BzzToken", false);

        vm.startBroadcast(deployer);
        postageStamp = address(new PostageStamp(bzzToken, 16));
        vm.stopBroadcast();
    }

    function run() public virtual {
        deploy("PostageStamp");
    }
}
