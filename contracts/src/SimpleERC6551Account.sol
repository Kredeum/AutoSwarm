// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC1271.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

import "./interfaces/IERC6551Account.sol";
import "./interfaces/IERC6551Executable.sol";

import {console} from "forge-std/console.sol";

contract SimpleERC6551Account is IERC165, IERC1271, IERC6551Account, IERC6551Executable {
    uint256 public state;
    address public me;

    function initialize() external {
        console.log("initialize  ", me);
        require(me == address(0));
        me = address(this);
        console.log("initialize  ", me);
    }

    receive() external payable {}

    function token() public view override returns (uint256, address, uint256) {
        console.log("token() 1", me);

        require(me != address(0));

        console.log("token() 2");

        address _me = me;
        bytes memory footer = new bytes(0x60);

        console.log("token() 3");

        assembly {
            extcodecopy(_me, add(footer, 0x20), 0x4d, 0x60)
        }
        console.log("token() 4");

        return abi.decode(footer, (uint256, address, uint256));
    }

    function execute(address to, uint256 value, bytes calldata data, uint256 operation)
        public
        payable
        virtual
        returns (bytes memory result)
    {
        console.log("execute:", msg.sender);

        require(_isValidSigner(msg.sender), "Invalid signer");
        require(operation == 0, "Only call operations are supported");

        ++state;

        bool success;
        (success, result) = to.call{value: value}(data);

        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }

    function isValidSigner(address signer, bytes calldata) public view virtual returns (bytes4) {
        if (_isValidSigner(signer)) {
            return IERC6551Account.isValidSigner.selector;
        }

        return bytes4(0);
    }

    function isValidSignature(bytes32 hash, bytes memory signature) public view virtual returns (bytes4 magicValue) {
        bool isValid = SignatureChecker.isValidSignatureNow(owner(), hash, signature);

        if (isValid) {
            return IERC1271.isValidSignature.selector;
        }

        return "";
    }

    function supportsInterface(bytes4 interfaceId) public pure virtual returns (bool) {
        return (
            interfaceId == type(IERC165).interfaceId || interfaceId == type(IERC6551Account).interfaceId
                || interfaceId == type(IERC6551Executable).interfaceId
        );
    }

    function owner() public view virtual returns (address) {
        (uint256 chainId, address tokenContract, uint256 tokenId) = token();
        if (chainId != block.chainid) return address(0);

        return IERC721(tokenContract).ownerOf(tokenId);
    }

    function _isValidSigner(address signer) internal view virtual returns (bool) {
        return signer == owner();
    }
}
