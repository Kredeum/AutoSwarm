// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import "./SetUpSwarm.t.sol";

contract PostageStampTest is SetUpSwarm {
    function setUp() public {
        setUpSwarm();
    }

    function test_PostageStamp_OK() public pure {
        assert(true);
    }

    function test_PostageStamp_amount() public view {
        assert((ttl0 << depth0) == (ttl0 * (2 ** depth0)));
    }

    function test_PostageStamp_buy() public {
        address buyer = msg.sender;
        uint256 buyInitialBalancePerChunk = 100000000000;
        uint8 buyDepth = 20;
        uint8 buyBucketDepth = minDepth;
        bytes32 buyNonce = keccak256(abi.encode(block.number));
        bool buyImmutable = true;

        uint256 totalAmount = buyInitialBalancePerChunk * (1 << buyDepth);
        bytes32 batchId = keccak256(abi.encode(buyer, buyNonce));

        deal(address(bzzToken), buyer, totalAmount);

        vm.startPrank(buyer);

        bzzToken.approve(address(postageStamp), totalAmount);

        postageStamp.createBatch(buyer, buyInitialBalancePerChunk, buyDepth, buyBucketDepth, buyNonce, buyImmutable);

        uint256 balance = postageStamp.remainingBalance(batchId);
        console.log("test_PostageStamp_buy ~ balance:", balance);

        assert(balance > 0);
    }
}
