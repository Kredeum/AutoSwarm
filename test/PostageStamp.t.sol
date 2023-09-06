// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import "./SetupSwarm.t.sol";

contract PostageStampTest is SetupSwarmTest {
    function test_postage_OK() public pure {
        assert(true);
    }

    // function test_postage_amount_fuzz(uint256 ttl, uint8 depth) public pure {
    //     vm.assume(depth < 128);
    //     vm.assume(ttl <= type(uint128).max);

    function test_postage_amount() public pure {
        uint256 ttl = 10 weeks;
        uint8 depth = 20;
        assert((ttl << depth) == (ttl * (2 ** depth)));
    }

    function test_postage_buy() public {
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
        console.log("test_postage_buy ~ balance:", balance);

        assert(balance > 0);
    }
}
