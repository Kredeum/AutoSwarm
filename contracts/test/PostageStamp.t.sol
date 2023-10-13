// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import "@autoswarm/test/SetUpSwarm.t.sol";

interface IPostageStampGnosis {
    function batches(bytes32 batchId)
        external
        view
        returns (address owner, uint8 depth, bool immutableFlag, uint256 normalisedBalance);
}

contract PostageStampTest is SetUpSwarm {
    function setUp() public {
        setRecording(false);
        setUpSwarm();
    }

    function test_PostageStamp_OK() public pure {
        assert(true);
    }

    // function test_PostageStamp_amount(uint256 ttl, uint8 depth) public view {
    //     vm.assume(depth <= 128);
    //     vm.assume(ttl <=  type(uint128).max);
    function test_PostageStamp_amount() public view {
        uint256 ttl = 10 weeks;
        uint8 depth = 20;
        assert((ttl << depth) == ttl * (1 << depth));
    }

    function test_PostageStamp_stampsBuy() public {
        address buyer = msg.sender;
        uint256 ttl = 1 days;
        uint8 depth = 20;
        uint8 buyBucketDepth = minDepth;
        bytes32 buyNonce = keccak256(abi.encode(block.number));
        bool buyImmutable = true;

        uint256 totalAmount = ttl << depth;

        deal(address(bzzToken), buyer, totalAmount);

        vm.startPrank(buyer);
        bzzToken.approve(address(postageStamp), totalAmount);
        postageStamp.createBatch(buyer, ttl, depth, buyBucketDepth, buyNonce, buyImmutable);

        bytes32 batchId = keccak256(abi.encode(buyer, buyNonce));
        uint256 balance = postageStamp.remainingBalance(batchId);
        console.log("test_PostageStamp_stampsBuy ~ balance:", balance);

        vm.stopPrank();

        assert(balance == ttl);

        uint256 lastPrice = postageStamp.lastPrice();
        vm.prank(oracle);
        postageStamp.setPrice(lastPrice + 1);

        vm.roll(postageStamp.lastUpdatedBlock() + 1);
        assert(postageStamp.remainingBalance(batchId) < ttl);
    }

    function test_PostageStamp_Gnosis_Batch() public {
        console.log("PostageStamp_Gnosis_Batch", block.chainid);

        if (block.chainid != 100) return;
        console.log("PostageStamp_Gnosis_Batch 1");

        bytes32 batchIdGnosis0 = 0xf20636dc0e9bc9f208ca4adbb43b3e538b9a4681437a7db992bd7617f7338fb1;
        bytes32 batchIdGnosis1 = 0x71d81776d3db5fa8b0c952bfa56295723ebc0b2d00901fb767217542951f016e;
        bytes32 batchId = batchIdGnosis1;

        (address owner, uint8 depth, bool const, uint256 nbal) =
            IPostageStampGnosis(address(postageStamp)).batches(batchId);
        console.log("PostageStamp_Gnosis_Batch 2");
        uint256 tbal = postageStamp.currentTotalOutPayment();
        console.log("PostageStamp_Gnosis_Batch 3");
        uint256 rbal = postageStamp.remainingBalance(batchId);
        console.log("PostageStamp_Gnosis_Batch 4");

        console.log("test_PostageStamp_Batch ~ rbal:", rbal);

        emit log_named_decimal_uint("test_PostageStamp_Batch ~ ttl jour", (rbal * 5) / (24 * 24 * 36), 5);

        // uint256 bzz = nbal << depth;
    }
}
