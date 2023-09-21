import 'viem/window';
import {
	createWalletClient,
	type Address,
	type Chain,
	type Hex,
	type PublicClient,
	type WalletClient,
	custom
} from 'viem';
import { autoSwarmAbi, bzzTokenAbi, registryAbi } from '$lib/ts/abis';
import { readJson, readChainId, readIsContract, readAccount } from '$lib/ts/read';
import { ONE_MONTH, ONE_YEAR } from './constants';

///////////////////////////////////////////////////////////////////////////////////////////////////
// WRITE : onchain write functions via rpc, i.e. functions with walletClient
///////////////////////////////////////////////////////////////////////////////////////////////////

const writeSalt = 1120920938n;

const writeWalletClient = async (chain: Chain): Promise<WalletClient> => {
	if (!window?.ethereum) {
		const message = 'Install Web3 extension like Rabby or Metamask';
		alert(message);
		throw new Error(message);
	}

	return createWalletClient({
		chain,
		transport: custom(window.ethereum!)
	});
};

const writeWalletAddress = async (walletClient: WalletClient): Promise<Address> => {
	return (await walletClient.requestAddresses())[0];
};

const writeCreateAccount = async (chain: Chain, publicClient: PublicClient) => {
	const chainId = await readChainId(publicClient);
	const json = await readJson(publicClient);

	const walletClient = await writeWalletClient(chain);
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

const writeStampsTopUp = async (chain: Chain, publicClient: PublicClient, topUpAmount: bigint) => {
	const json = await readJson(publicClient);
	const walletClient = await writeWalletClient(chain);
	const walletAddress = await writeWalletAddress(walletClient);
	const autoSwarmAddress = await readAccount(publicClient);

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

const writeApproveBzz = async (chain: Chain, publicClient: PublicClient, bzzAmount: bigint) => {
	const json = await readJson(publicClient);
	const walletClient = await writeWalletClient(chain);
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

const writeTopUp = async (chain: Chain, publicClient: PublicClient) => {
	const autoSwarmAddress = await readAccount(publicClient);
	console.log('writeTopUp ~ autoSwarmAddress:', autoSwarmAddress);

	if (!(await readIsContract(publicClient, autoSwarmAddress))) {
		console.log('writeTopUp ~ create');

		await writeCreateAccount(chain, publicClient);
	}
	console.log('writeTopUp ~ follow');

	// TopUp one hour TTL
	const topUpttl: bigint = (BigInt(ONE_MONTH) * 24000n) / 5n;

	// const topUpBzz: bigint = topUpttl * 2n ** 17n;
	// await writeApproveBzz(chain, publicClient, topUpBzz);

	await writeStampsTopUp(chain, publicClient, topUpttl);
};

export { writeCreateAccount, writeTopUp, writeApproveBzz, writeSalt };
