// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DeployNFTCollection} from "./deploy/00_DeployNFTCollection.s.sol";
import {DeployBzzToken} from "./deploy/01_DeployBzzToken.s.sol";
import {DeployPostageStamp} from "./deploy/02_DeployPostageStamp.s.sol";
import {DeployERC6551Registry} from "./deploy/03_DeployERC6551Registry.s.sol";
import {DeployAutoSwarmAccount} from "./deploy/04_DeployAutoSwarmAccount.s.sol";

contract DeployAll is
    DeployNFTCollection,
    DeployBzzToken,
    DeployPostageStamp,
    DeployERC6551Registry,
    DeployAutoSwarmAccount
{
    function run()
        public
        override(DeployNFTCollection, DeployBzzToken, DeployPostageStamp, DeployERC6551Registry, DeployAutoSwarmAccount)
    {
        deploy("NFTCollection", false);
        deploy("BzzToken", false);
        deploy("PostageStamp", false);
        deploy("ERC6551Registry", false);
        deploy("AutoSwarmAccount");

        writeAddresses();
    }
}
