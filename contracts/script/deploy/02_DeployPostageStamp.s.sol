// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {DeployLite} from "@forge-deploy-lite/DeployLite.s.sol";
import {PostageStamp} from "storage-incentives/PostageStamp.sol";
import {DeployBzzToken} from "./01_DeployBzzToken.s.sol";

contract DeployPostageStamp is DeployLite {
    function deployPostageStamp() public returns (address postageStamp) {
        address bzzToken = readAddress("BzzToken");

        bytes memory args = abi.encode(bzzToken, 16);
        DeployState state = deployState("PostageStamp", args);

        if (state == DeployState.None) {
            vm.startBroadcast();

            postageStamp = deploy("PostageStamp", args);
            bytes32 oracleRole = PostageStamp(postageStamp).PRICE_ORACLE_ROLE();
            PostageStamp(postageStamp).grantRole(oracleRole, msg.sender);
            PostageStamp(postageStamp).setPrice(24000);

            vm.stopBroadcast();
        }
    }

    function run() public virtual {
        deployPostageStamp();
    }
}
