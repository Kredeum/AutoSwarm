// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {TestToken} from "storage-incentives/TestToken.sol";

contract BzzToken is TestToken("BZZ TEST", "TBZZ", 1e25, msg.sender) {}
