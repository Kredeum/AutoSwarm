// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {ReadWriteJson} from "lib/forge-deploy-lite/script/ReadWriteJson.sol";
import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";

interface IBzz {
    function bzzToken() external returns (address);
}

contract StorageIncentivesForkTest is Test, ReadWriteJson {
    address postageStamp;
    address bzzToken;

    function setUp() public {
        postageStamp = readAddress("PostageStamp");
        bzzToken = readAddress("BzzToken");


        require(
            (postageStamp.code.length > 0) && (bzzToken.code.length > 0), "BAD NETWORK: no postageStamp or bzzToken"
        );
    }

    function test_incentives_OK() public pure {
        assert(true);
    }

    // BZZTOKEN
    function test_incentives_bzzToken() public view {
        console.log("bzzToken:", bzzToken, bzzToken.code.length);
        assert(bzzToken.code.length > 0);
    }

    function test_incentives_bzzToken_totalSupply() public view {
        assert(IERC20(bzzToken).totalSupply() > 0);
    }

    // POSTAGESTAMP
    function test_incentives_postageStamp() public view {
        console.log("postageStamp:", postageStamp, postageStamp.code.length);
        assert(postageStamp.code.length > 0);
    }

    function test_incentives_postageStamp_bzzToken() public {
        console.log("postageStamp:", postageStamp, postageStamp.code.length);
        assert(postageStamp.code.length > 0);

        assert(IBzz(postageStamp).bzzToken() == bzzToken);
    }
}
