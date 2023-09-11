// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DeployNFTCollection} from "./deploy/00_DeployNFTCollection.s.sol";
import {DeployBzzToken} from "./deploy/01_DeployBzzToken.s.sol";
import {DeployERC6551Registry} from "./deploy/02_DeployERC6551Registry.s.sol";
import {DeployAutoSwarmAccount} from "./deploy/03_DeployAutoSwarmAccount.s.sol";
import {DeployPostageStamp} from "./deploy/04_DeployPostageStamp.s.sol";


contract DeployAll is
    DeployBzzToken,
    DeployNFTCollection,
    DeployERC6551Registry,
    DeployAutoSwarmAccount,
    DeployPostageStamp
{
    function run()
        public
        override(
            DeployBzzToken,
            DeployNFTCollection,
            DeployERC6551Registry,
            DeployAutoSwarmAccount,
            DeployPostageStamp
        )
    {
        deploy("BzzToken", false);
        deploy("NFTCollection", false);
        deploy("ERC6551Registry");
        deploy("AutoSwarmAccount");
        deploy("PostageStamp", false);

        writeAddresses();
    }
}
