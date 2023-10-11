// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DeployLite} from "@forge-deploy-lite/DeployLite.s.sol";
import {PostageStamp} from "@storage-incentives/PostageStamp.sol";

contract DeployPostageStamp is DeployLite {
    function deployPostageStamp() public returns (address postageStamp) {
        address bzzToken = deploy("BzzToken");
        address admin = getAddress("Admin");

        vm.startBroadcast(deployer);
        postageStamp = address(new PostageStamp(bzzToken, 16, admin));
        vm.stopBroadcast();
    }

    function run() public virtual {
        deploy("PostageStamp");
    }
}
