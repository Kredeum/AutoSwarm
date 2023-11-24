// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IERC20} from "./IERC20.sol";
import {IAutoSwarmMarket} from "./IAutoSwarmMarket.sol";

interface IAutoSwarmAccount {
    function initialize(address, bytes32, uint256) external;

    function topUp(uint256) external;

    function bzzHash() external view returns (bytes32);
    function swarmSize() external view returns (uint256);

    function getTopUpYearPrice() external view returns (uint256);
}
