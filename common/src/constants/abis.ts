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
	'function topUp(bytes32,uint256) external',
	'function currentTotalOutPayment() external view returns (uint256)',
	'function createBatch(address,uint256,uint8,uint8,bytes32,bool) external returns (bytes32)'
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

const autoSwarmAccountAbi = parseAbi([
	'error StampExists()',
	'error NotTba()',
	'error NotOwner()',
	'error NotMarketOwner()',
	'error SwarmSizeZero()',
	'error SwarmHashNull()',
	'error AutoSwarmMarketNull()',
	'error NotEnoughBalance(uint256, uint256)',
	'error AmountZero()',
	'function token() external view returns (uint256, address, uint256)',
	'function swarmHash() external view returns (bytes32)',
	'function swarmSize() external view returns (uint256)',
	'function stampId() external view returns (bytes32)',
	'function createStamp(bytes32, uint256, uint256) external returns (bytes32)',
	'function topUp(uint256) external',
	'function getOneYearPrice() external view returns (uint256)',
	'function withdraw(address) external'
]);

const autoSwarmMarketAbi = parseAbi([
	'error NodeOwnerNull()',
	'error InvalidBatch()',
	'error BatchExists()',
	'error StampExists()',
	'error StampNull()',
	'error NotOwner()',
	'error NotMarketOwner()',
	'error SwarmSizeZero()',
	'error SwarmMbSizeZero()',
	'error SwarmHashNull()',
	'error AutoSwarmMarketNull()',
	'error PostageStampNull()',
	'error NotEnoughBalance(uint256, uint256)',
	'error TransferFailed()',
	'error AmountZero()',
	'function currentNodeOwner() external view returns (address)',
	'function getStampsCount() external view returns (uint256)',
	'function currentBatchFilling() external view returns (uint256)',
	'function getStampRemainingBalance(bytes32) external view returns (uint256)',
	'function getStampIds(uint256, uint256) external view returns (bytes32[] memory, bytes32[] memory)',
	'function getStampIdsToAttach(uint256, uint256) external view returns (bytes32[] memory)',
	'function currentBatchId() external view returns (bytes32)',
	'function stampToBatchId(bytes32) external view returns (bytes32)',
	'function lastPrice() external view returns(uint64)',
	'function newBatchNeeded() external view returns (bool)',
	'function sync() external',
	'function stamps(bytes32) external view returns (address, bytes32, uint256, uint256)',
	'function attachStamps(bytes32[] memory, bytes32) external',
	'function newBatch(uint256) external returns (bytes32)',
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
	autoSwarmMarketAbi
};
