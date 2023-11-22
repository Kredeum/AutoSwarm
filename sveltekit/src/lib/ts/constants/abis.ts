import { parseAbi } from 'viem';

///////////////////////////////////////////////////////////////////////////////////////////////////
// ABIS : interfaces to send functions
///////////////////////////////////////////////////////////////////////////////////////////////////

const postageStampAbiBatcheslegacy = parseAbi([
	'function batches(bytes32) external view returns(address,uint8,bool,uint256)'
]);
const postageStampAbi = parseAbi([
	'function remainingBalance(bytes32) external view returns(uint256)',
	'function batches(bytes32) external view returns(address,uint8,uint8,bool,uint256,uint256)',
	'function lastPrice() external view returns (uint64)',
	'function topUp(bytes32,uint256) external'
]);
const erc165Abi = parseAbi(['function supportsInterface(bytes4) external view returns (bool)']);
const erc20Abi = parseAbi([
	'function balanceOf(address) external view returns(uint256)',
	'function approve(address,uint256) external returns (bool)',
	'function transfer(address,uint256) external returns (bool)'
]);
const erc721Abi = parseAbi([
	'function ownerOf(uint256) external view returns (address)',
	'function tokenURI(uint256) external view returns (string)',
	'function totalSupply() external view returns (uint256)'
]);
const erc1155Abi = parseAbi(['function uri(uint256) external view returns (string)']);
const erc6551RegistryAbi = parseAbi([
	'function account(address,bytes32,uint256,address,uint256) external view returns (address)',
	'function createAccount(address,bytes32,uint256,address,uint256) external returns (address)'
]);
const autoSwarmAccountAbi2 = parseAbi(['function initialize(address,bytes32,uint256) external']);
const autoSwarmAccountAbi = parseAbi([
	'function initialize(address,bytes32,uint256) external',
	'function topUp(uint256) external',
	'function getTopUpYearPrice() external view returns (uint256)',
	'function withdraw(address) external'
]);
const autoSwarmMarketAbi = parseAbi([
	'function newBatch() public returns (bytes32)',
	'function currentBatchId() external view returns (bytes32)',
	'function extendsBatch(bytes32,uint8) external'
]);

export {
	erc165Abi,
	erc20Abi,
	erc721Abi,
	erc1155Abi,
	erc6551RegistryAbi,
	postageStampAbiBatcheslegacy,
	postageStampAbi,
	autoSwarmAccountAbi,
	autoSwarmAccountAbi2,
	autoSwarmMarketAbi
};
