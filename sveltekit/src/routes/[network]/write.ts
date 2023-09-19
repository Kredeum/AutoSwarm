import type { Address, Hex, PublicClient, WalletClient } from 'viem';
import { autoSwarmAbi, bzzTokenAbi, registryAbi } from './abis';
import { readJson, readChainId, readIsContract, readAccount } from './read';

///////////////////////////////////////////////////////////////////////////////////////////////////
// WRITE : onchain write functions via rpc, i.e. functions with walletClient
///////////////////////////////////////////////////////////////////////////////////////////////////

const writeSalt = 1120920938n;

const writeWalletAddress = async (walletClient: WalletClient): Promise<Address> => {
	return (await walletClient.requestAddresses())[0];
};

const writeCreateAccount = async (publicClient: PublicClient, walletClient: WalletClient) => {
	const chainId = await readChainId(publicClient);
	const json = await readJson(publicClient);
	const walletAddress = await writeWalletAddress(walletClient);
	const autoSwarmAddress = await readAccount(publicClient);

	console.log(
		'writeCreateAccount ~ chainId walletAddress:',
		chainId,
		walletAddress,
		autoSwarmAddress
	);

	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: json.ERC6551Registry as Address,
		abi: registryAbi,
		functionName: 'createAccount',
		args: [
			json.AutoSwarmAccount as Address,
			BigInt(chainId),
			json.NFTCollection as Address,
			BigInt(1),
			writeSalt,
			''
		]
	});
	const hash = await walletClient.writeContract(request);
	await publicClient.waitForTransactionReceipt({ hash: hash });

	if (!(await readIsContract(publicClient, autoSwarmAddress))) throw Error('Create failed');
};

const writeStampsTopUp = async (
	publicClient: PublicClient,
	walletClient: WalletClient,
	topUpAmount: bigint
) => {
	const json = await readJson(publicClient);
	const walletAddress = await writeWalletAddress(walletClient);
	const autoSwarmAddress = await readAccount(publicClient);

	// const { request } = await publicClient.simulateContract({
	// 	account: walletAddress,
	// 	address: autoSwarmAddress,
	// 	abi: autoSwarmAbi,
	// 	functionName: 'stampsTopUp',
	// 	args: [json.batchId as Hex, topUpAmount]
	// });
	// const hash = await walletClient.writeContract(request);
	const hash = await walletClient.writeContract({
		account: walletAddress,
		address: autoSwarmAddress,
		abi: autoSwarmAbi,
		functionName: 'stampsTopUp',
		args: [json.batchId as Hex, topUpAmount]
	});
	await publicClient.waitForTransactionReceipt({ hash });
};

const writeApproveBzz = async (
	publicClient: PublicClient,
	walletClient: WalletClient,
	bzzAmount: bigint
) => {
	const json = await readJson(publicClient);
	const walletAddress = await writeWalletAddress(walletClient);

	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: json.BzzToken as Address,
		abi: bzzTokenAbi,
		functionName: 'approve',
		args: [json.PostageStamp as Address, bzzAmount]
	});

	const hash = await walletClient.writeContract(request);
	await publicClient.waitForTransactionReceipt({ hash });
};

const writeTopUp = async (publicClient: PublicClient, walletClient: WalletClient) => {
	const autoSwarmAddress = await readAccount(publicClient);

	if (!(await readIsContract(publicClient, autoSwarmAddress))) {
		await writeCreateAccount(publicClient, walletClient);
	}

	// TopUp one hour TTL
	const topUpttl: bigint = (24000n / 5n) * 3600n;

	// const topUpBzz: bigint = topUpttl * 2n ** 17n;
	// await writeApproveBzz(publicClient, walletClient, topUpBzz);

	await writeStampsTopUp(publicClient, walletClient, topUpttl);
};

export { writeCreateAccount, writeTopUp, writeApproveBzz, writeSalt };
