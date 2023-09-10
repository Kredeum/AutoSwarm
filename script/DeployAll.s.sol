// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DeployContracts} from "script/DeployContracts.s.sol";
import {console} from "forge-std/Test.sol";

contract DeployAll is DeployContracts {
    function run() public {
        deploy("BzzToken", false);
        deploy("NFTCollection", false);
        deploy("ERC6551Registry");
        deploy("SimpleERC6551Account");
        deploy("PostageStamp", false);
        deploy("AutoSwarm");

        writeAddresses();
    }
}
