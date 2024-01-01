// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {TestToken} from "storage-incentives/TestToken.sol";

contract BzzToken is TestToken("BZZ TEST", "TBZZ", 1e20) {}
