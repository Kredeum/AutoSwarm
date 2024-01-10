// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {DeployLite} from "@forge-deploy-lite/DeployLite.s.sol";
import {PostageStamp} from "storage-incentives/PostageStamp.sol";
import {DeployBzzToken} from "./01_DeployBzzToken.s.sol";

import {console} from "forge-std/console.sol";

contract DeployPostageStamp is DeployLite, DeployBzzToken {
    function deployPostageStamp() public returns (address) {
        address bzzToken = deployBzzToken();

        bytes memory args = abi.encode(bzzToken, 16);
        DeployState state = deployState("PostageStamp", args);

        if (state == DeployState.None) {
            vm.startBroadcast();

            address postageStamp = deploy("PostageStamp", args);
            bytes32 oracleRole = PostageStamp(postageStamp).PRICE_ORACLE_ROLE();
            PostageStamp(postageStamp).grantRole(oracleRole, msg.sender);
            PostageStamp(postageStamp).setPrice(24000);

            vm.stopBroadcast();
        }

        return readAddress("PostageStamp");
    }

    function run() public virtual override(DeployBzzToken) {
        deployPostageStamp();
    }
}
