import 'viem/window';
import type { Address, Chain, Hex, PublicClient } from 'viem';
import { autoSwarmAbi, bzzTokenAbi } from '$lib/ts/abis';
import { readJson, readAccount, readLastPrice } from '$lib/ts/read';
import { DEFAULT_PRICE, ONE_MONTH } from './constants';
import { writeCreateAccount, writeWalletAddress, writeWalletClient } from './write';
import { utilsTtlToNBal } from './utils';

///////////////////////////////////////////////////////////////////////////////////////////////////
// WRITE : onchain write functions via rpc, i.e. functions with walletClient
///////////////////////////////////////////////////////////////////////////////////////////////////

const writeStampsTopUp = async (chain: Chain, publicClient: PublicClient, topUpAmount: bigint) => {
	await writeCreateAccount(chain, publicClient);

	const json = await readJson(publicClient);
	const walletClient = await writeWalletClient(chain);
	const walletAddress = await writeWalletAddress(walletClient);
	const autoSwarmAddress = await readAccount(publicClient);
	if (!('batchId' in json)) throw Error('No batchId in json');

	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: autoSwarmAddress,
		abi: autoSwarmAbi,
		functionName: 'stampsTopUp',
		args: [json.batchId as Hex, topUpAmount]
	});
	const hash = await walletClient.writeContract(request);
	await publicClient.waitForTransactionReceipt({ hash });
};

const writeStampsIncreaseDepth = async (
	chain: Chain,
	publicClient: PublicClient,
	newDepth = 23
) => {
	await writeCreateAccount(chain, publicClient);

	const json = await readJson(publicClient);
	const walletClient = await writeWalletClient(chain);
	const walletAddress = await writeWalletAddress(walletClient);
	const autoSwarmAddress = await readAccount(publicClient);
	if (!('batchId' in json)) throw Error('No batchId in json');

	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: autoSwarmAddress,
		abi: autoSwarmAbi,
		functionName: 'stampsIncreaseDepth',
		args: [json.batchId as Hex, newDepth]
	});
	const hash = await walletClient.writeContract(request);
	await publicClient.waitForTransactionReceipt({ hash });
};

const writeStampsBuy = async (chain: Chain, publicClient: PublicClient) => {
	await writeCreateAccount(chain, publicClient);

	const autoSwarmAddress = await readAccount(publicClient);
	const walletClient = await writeWalletClient(chain);
	const walletAddress = await writeWalletAddress(walletClient);
	const lastPrice = (await readLastPrice(publicClient)) || DEFAULT_PRICE;
	const buyTtl = utilsTtlToNBal(BigInt(ONE_MONTH), lastPrice);
	const depth = 17;
	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: autoSwarmAddress,
		abi: autoSwarmAbi,
		functionName: 'stampsBuy',
		args: [buyTtl, depth]
	});
	const hash = await walletClient.writeContract(request);
	await publicClient.waitForTransactionReceipt({ hash });
};

const writeStampsDeposit = async (chain: Chain, publicClient: PublicClient) => {
	const json = await readJson(publicClient);
	const walletClient = await writeWalletClient(chain);
	const walletAddress = await writeWalletAddress(walletClient);
	const autoSwarmAddress = await readAccount(publicClient);

	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: json.BzzToken as Address,
		abi: bzzTokenAbi,
		functionName: 'transfer',
		args: [autoSwarmAddress, 2n * 10n ** 16n]
	});
	const hash = await walletClient.writeContract(request);
	await publicClient.waitForTransactionReceipt({ hash });
};

const writeStampsWithdraw = async (chain: Chain, publicClient: PublicClient) => {
	await writeCreateAccount(chain, publicClient);

	const walletClient = await writeWalletClient(chain);
	const walletAddress = await writeWalletAddress(walletClient);
	const autoSwarmAddress = await readAccount(publicClient);

	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: autoSwarmAddress,
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
