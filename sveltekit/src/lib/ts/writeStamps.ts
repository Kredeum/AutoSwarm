import 'viem/window';
import type { Address, Chain, Hex } from 'viem';
import { autoSwarmAbi, bzzTokenAbi } from '$lib/ts/abis';
import { readJson, readAccount, readLastPrice, readPublicClient } from '$lib/ts/read';
import { DEFAULT_PRICE, ONE_MONTH } from './constants';
import { writeWallet, writeCreateAccount } from './write';
import { utilsError, utilsTtlToNBal } from './utils';

///////////////////////////////////////////////////////////////////////////////////////////////////
// WRITE : onchain write functions via rpc, i.e. functions with walletClient
///////////////////////////////////////////////////////////////////////////////////////////////////

const writeStampsTopUp = async (chain: Chain, topUpAmount: bigint) => {
	await writeCreateAccount(chain);

	const json = await readJson(chain);

	const [publicClient, walletClient, walletAddress] = await writeWallet(chain);

	const autoSwarmAddress = await readAccount(chain);

	if (!('batchId' in json)) utilsError('No batchId in json');

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

const writeStampsIncreaseDepth = async (chain: Chain, newDepth = 23) => {
	await writeCreateAccount(chain);

	const json = await readJson(chain);

	const [publicClient, walletClient, walletAddress] = await writeWallet(chain);

	const autoSwarmAddress = await readAccount(chain);
	if (!('batchId' in json)) utilsError('No batchId in json');

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

const writeStampsBuy = async (chain: Chain) => {
	await writeCreateAccount(chain);

	const autoSwarmAddress = await readAccount(chain);

	const [publicClient, walletClient, walletAddress] = await writeWallet(chain);

	const lastPrice = (await readLastPrice(chain)) || DEFAULT_PRICE;
	const buyTtl = utilsTtlToNBal(ONE_MONTH, lastPrice);
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

const writeStampsDeposit = async (chain: Chain) => {
	const json = await readJson(chain);

	const [publicClient, walletClient, walletAddress] = await writeWallet(chain);

	const autoSwarmAddress = await readAccount(chain);

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

const writeStampsWithdraw = async (chain: Chain) => {
	await writeCreateAccount(chain);

	const [publicClient, walletClient, walletAddress] = await writeWallet(chain);

	const autoSwarmAddress = await readAccount(chain);

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
