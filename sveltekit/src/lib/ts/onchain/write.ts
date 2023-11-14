import 'viem/window';
import {
	createWalletClient,
	type Address,
	type WalletClient,
	type EIP1193Provider,
	custom,
	BaseError,
	ContractFunctionRevertedError,
	encodeFunctionData,
	type PublicClient
} from 'viem';
import { autoSwarmAbi, bzzTokenAbi, erc6551RegistryAbi } from '$lib/ts/constants/abis';
import { readIsContract, readPublicClient } from '$lib/ts/onchain/read';
import { SALT } from '../constants/constants';
import { utilsError } from '../swarm/utils';
import { jsonGet } from '../constants/json';
import { chainGet } from '../constants/chains';

///////////////////////////////////////////////////////////////////////////////////////////////////
// WRITE : onchain write functions via rpc, i.e. functions with walletClient
///////////////////////////////////////////////////////////////////////////////////////////////////

const _writeWindowEthereum = (): EIP1193Provider => {
	if (!window?.ethereum) utilsError('Install Web3 extension like Rabby or Metamask');

	return window.ethereum!;
};

const _writeWalletEthereum = (): WalletClient => {
	return createWalletClient({
		transport: custom(_writeWindowEthereum())
	});
};

const writeWallet = async (chainId: number): Promise<[PublicClient, WalletClient, Address]> => {
	const publicClient = await readPublicClient(chainId);
	const walletClient = await writeWalletClient(chainId);
	const walletAddress = await writeWalletAddress(walletClient, true);

	return [publicClient, walletClient, walletAddress];
};

const writeWalletAddress = async (
	walletClient = _writeWalletEthereum(),
	force = false,
	n = 0
): Promise<Address> => {
	return force
		? (await walletClient.requestAddresses())[n]
		: (await walletClient.getAddresses())[n];
};

const writeWalletClient = async (chainId: number): Promise<WalletClient> => {
	const ethereum = _writeWindowEthereum();
	const chain = chainGet(chainId);

	const walletClient = createWalletClient({
		chain,
		transport: custom(ethereum)
	});

	if (chainId > 0 && chainId !== chainId) {
		console.log('writeWalletClient switchChain', chainId, chainId);
		await walletClient.switchChain({ id: chainId });
	}

	return walletClient;
};

const writeCreateAccount = async (
	chainId: number,
	collection: Address,
	tokenId: bigint,
	tba: Address
): Promise<Address> => {
	if (await readIsContract(chainId, tba)) return tba;

	const json = await jsonGet(chainId);

	const [publicClient, walletClient, walletAddress] = await writeWallet(chainId);

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
			args: [json.AutoSwarmAccount as Address, BigInt(chainId), collection, tokenId, SALT, data]
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

	if (!(await readIsContract(chainId, tba))) utilsError('Create failed');

	return tba;
};

const writeApproveBzz = async (chainId: number, bzzAmount: bigint) => {
	const json = await jsonGet(chainId);

	const [publicClient, walletClient, walletAddress] = await writeWallet(chainId);

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

const writeTransferBzz = async (chainId: number, to: Address, bzzAmount: bigint) => {
	const json = await jsonGet(chainId);

	const [publicClient, walletClient, walletAddress] = await writeWallet(chainId);

	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: json.BzzToken as Address,
		abi: bzzTokenAbi,
		functionName: 'transfer',
		args: [to as Address, bzzAmount]
	});

	const hash = await walletClient.writeContract(request);
	await publicClient.waitForTransactionReceipt({ hash });
};

export {
	writeWallet,
	writeWalletClient,
	writeWalletAddress,
	writeCreateAccount,
	writeApproveBzz,
	writeTransferBzz
};
