import 'viem/window';
import {
	createWalletClient,
	type Address,
	type Chain,
	type PublicClient,
	type WalletClient,
	custom,
	BaseError,
	ContractFunctionRevertedError,
	encodeFunctionData
} from 'viem';
import { autoSwarmAbi, bzzTokenAbi, erc6551RegistryAbi } from '$lib/ts/abis';
import { readJson, readChainId, readIsContract, readAccount } from '$lib/ts/read';
import { SALT } from './constants';

///////////////////////////////////////////////////////////////////////////////////////////////////
// WRITE : onchain write functions via rpc, i.e. functions with walletClient
///////////////////////////////////////////////////////////////////////////////////////////////////

const writeWalletClient = async (chain: Chain): Promise<WalletClient> => {
	if (!window?.ethereum) {
		const message = 'Install Web3 extension like Rabby or Metamask';
		alert(message);
		throw new Error(message);
	}

	const walletClient = createWalletClient({
		chain,
		transport: custom(window.ethereum!)
	});
	if ((await walletClient.getChainId()) !== chain.id) {
		await walletClient.switchChain({ id: chain.id });
	}

	return walletClient;
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

	try {
		const data = encodeFunctionData({
			abi: autoSwarmAbi,
			functionName: 'initialize',
			args: [json.PostageStamp as Address]
		});

		const { request } = await publicClient.simulateContract({
			account: walletAddress,
			address: json.ERC6551Registry as Address,
			abi: erc6551RegistryAbi,
			functionName: 'createAccount',
			args: [
				json.AutoSwarmAccount as Address,
				BigInt(chainId),
				json.NFTCollection as Address,
				BigInt(json.tokenId),
				SALT,
				data
			]
		});
		const hash = await walletClient.writeContract(request);
		await publicClient.waitForTransactionReceipt({ hash: hash });
	} catch (err) {
		if (err instanceof BaseError) {
			const revertError = err.walk((err) => err instanceof ContractFunctionRevertedError);
			if (revertError instanceof ContractFunctionRevertedError) {
				const errorName = revertError.data?.errorName ?? '';
				console.error('writeCreateAccount ~ errorName:', errorName);
			}
		}
	}

	if (!(await readIsContract(publicClient, autoSwarmAddress))) throw Error('Create failed');
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

export { writeCreateAccount, writeApproveBzz, writeWalletClient, writeWalletAddress };
