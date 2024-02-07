// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// https://eips.ethereum.org/EIPS/eip-1155
/// @title ERC-1155 Multi Token Standard 0xd9b67a26
interface IERC1155 {  
    event TransferSingle(address indexed, address indexed, address indexed, uint256, uint256);
    event TransferBatch(address indexed, address indexed, address indexed, uint256[], uint256[]);
    event ApprovalForAll(address indexed, address indexed, bool);
    event URI(string, uint256 indexed);

    function safeTransferFrom(address, address, uint256, uint256, bytes calldata) external;
    function safeBatchTransferFrom(address, address, uint256[] calldata, uint256[] calldata, bytes calldata) external;
    function setApprovalForAll(address, bool) external;

    function balanceOf(address, uint256) external view returns (uint256);
    function balanceOfBatch(address[] calldata, uint256[] calldata) external view returns (uint256[] memory);
    function isApprovedForAll(address, address) external view returns (bool);
}
