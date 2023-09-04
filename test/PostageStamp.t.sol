// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {ReadWriteJson} from "lib/forge-deploy-lite/script/ReadWriteJson.sol";
import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";
import {PostageStamp} from "lib/storage-incentives/src/PostageStamp.sol";

contract PostageStampTest is Test, ReadWriteJson {
    PostageStamp postageStamp;
    IERC20 bzzToken;

    function setUp() public {
        postageStamp = PostageStamp(readAddress("PostageStamp"));
        bzzToken = IERC20(readAddress("BzzToken"));

        uint256 postageStampCodeLength = address(postageStamp).code.length;
        uint256 bzzTokenCodeLength = address(bzzToken).code.length;

        if (postageStampCodeLength == 0 || bzzTokenCodeLength == 0) {
            console.log("bzzToken:", address(bzzToken), bzzTokenCodeLength);
            console.log("postageStamp:", address(postageStamp), postageStampCodeLength);
            revert("BAD NETWORK or ADDRESSES: no postageStamp or bzzToken");
        }
    }

    function test_buyOK() public pure {
        assert(true);
    }

    function test_postage_buy() public {
        address buyer = msg.sender;
        uint256 buyInitialBalancePerChunk = 100000000000;
        uint8 buyDepth = 20;
        uint8 buyBucketDepth = 16;
        bytes32 buyNonce = keccak256(abi.encode(block.number));
        bool buyImmutable = true;

        uint256 totalAmount = buyInitialBalancePerChunk * (1 << buyDepth);
        bytes32 batchId = keccak256(abi.encode(buyer, buyNonce));

        deal(address(bzzToken), buyer, totalAmount);

        vm.startPrank(buyer);

        bzzToken.approve(address(postageStamp), totalAmount);

        postageStamp.createBatch(buyer, buyInitialBalancePerChunk, buyDepth, buyBucketDepth, buyNonce, buyImmutable);

        uint256 balance = postageStamp.remainingBalance(batchId);
        console.log("test_postage_buy ~ balance:", balance);

        assert(balance > 0);
    }
}
