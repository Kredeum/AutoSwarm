import 'viem/window';
import type { Address, Hex } from 'viem';
import { autoSwarmAbi, bzzTokenAbi } from '$lib/ts/constants/abis';
import { readLastPrice } from '$lib/ts/onchain/read';
import { DEFAULT_PRICE, ONE_MONTH } from '../constants/constants';
import { writeWallet } from './write';
import { utilsError, utilsTtlToNBal } from '../swarm/utils';
import { jsonGet } from '../constants/json';

///////////////////////////////////////////////////////////////////////////////////////////////////
// WRITE : onchain write functions via rpc, i.e. functions with walletClient
///////////////////////////////////////////////////////////////////////////////////////////////////

const writeStampsTopUp = async (chainId: number, tba: Address, topUpAmount: bigint) => {
	if (!(chainId > 0 && tba)) utilsError('No tba');

	const json = await jsonGet(chainId);

	const [publicClient, walletClient, walletAddress] = await writeWallet(chainId);

	if (!('batchId' in json)) utilsError('No batchId in json');

	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: tba,
		abi: autoSwarmAbi,
		functionName: 'stampsTopUp',
		args: [json.batchId as Hex, topUpAmount]
	});
	const hash = await walletClient.writeContract(request);
	await publicClient.waitForTransactionReceipt({ hash });
};

const writeStampsIncreaseDepth = async (chainId: number, tba: Address, newDepth = 23) => {
	if (!(chainId > 0 && tba)) utilsError('No tba');

	const json = await jsonGet(chainId);

	const [publicClient, walletClient, walletAddress] = await writeWallet(chainId);

	if (!('batchId' in json)) utilsError('No batchId in json');

	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: tba,
		abi: autoSwarmAbi,
		functionName: 'stampsIncreaseDepth',
		args: [json.batchId as Hex, newDepth]
	});
	const hash = await walletClient.writeContract(request);
	await publicClient.waitForTransactionReceipt({ hash });
};

const writeStampsBuy = async (chainId: number, tba: Address) => {
	if (!(chainId > 0 && tba)) utilsError('No tba');

	const [publicClient, walletClient, walletAddress] = await writeWallet(chainId);

	const lastPrice = (await readLastPrice(chainId)) || DEFAULT_PRICE;
	const buyTtl = utilsTtlToNBal(ONE_MONTH, lastPrice)!;
	const depth = 17;
	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: tba,
		abi: autoSwarmAbi,
		functionName: 'stampsBuy',
		args: [buyTtl, depth]
	});
	const hash = await walletClient.writeContract(request);
	await publicClient.waitForTransactionReceipt({ hash });
};

const writeStampsDeposit = async (chainId: number, tba: Address) => {
	if (!(chainId > 0 && tba)) utilsError('No tba');

	const json = await jsonGet(chainId);

	const [publicClient, walletClient, walletAddress] = await writeWallet(chainId);

	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: json.BzzToken as Address,
		abi: bzzTokenAbi,
		functionName: 'transfer',
		args: [tba, 2n * 10n ** 16n]
	});
	const hash = await walletClient.writeContract(request);
	await publicClient.waitForTransactionReceipt({ hash });
};

const writeStampsWithdraw = async (chainId: number, tba: Address) => {
	if (!(chainId > 0 && tba)) utilsError('No tba');

	const [publicClient, walletClient, walletAddress] = await writeWallet(chainId);

	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: tba,
		abi: autoSwarmAbi,
		functionName: 'withdrawBzz'
	});
	const hash = await walletClient.writeContract(request);
	await publicClient.waitForTransactionReceipt({ hash });
};

export {
	writeStampsBuy,
	writeStampsTopUp,
	writeStampsIncreaseDepth,
	writeStampsWithdraw,
	writeStampsDeposit
};
