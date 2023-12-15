// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IAutoSwarmAccount {
    function autoSwarmMarket() external view returns (address);

    function topUp(uint256) external;

    function bzzHash() external view returns (bytes32);
    function bzzSize() external view returns (uint256);

    function getTopUpYearPrice() external view returns (uint256);
}
