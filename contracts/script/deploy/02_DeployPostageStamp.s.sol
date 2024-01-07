// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {DeployLite} from "@forge-deploy-lite/DeployLite.s.sol";
import {PostageStamp} from "storage-incentives/PostageStamp.sol";
import {DeployBzzToken} from "./01_DeployBzzToken.s.sol";

contract DeployPostageStamp is DeployLite {
    function deployPostageStamp() public returns (address) {
        address bzzToken = readAddress("BzzToken");

        (address postageStamp, DeployedState state) = deploy("PostageStamp", abi.encode(bzzToken, 16), false);

        if (state == DeployedState.Newly) {
            vm.startBroadcast();
            bytes32 oracleRole = PostageStamp(postageStamp).PRICE_ORACLE_ROLE();
            PostageStamp(postageStamp).grantRole(oracleRole, msg.sender);
            PostageStamp(postageStamp).setPrice(24000);
            vm.stopBroadcast();
        }

        return postageStamp;
    }

    function run() public virtual {
        deployPostageStamp();
    }
}
