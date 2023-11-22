import 'viem/window';
import {
	createWalletClient,
	type Address,
	type WalletClient,
	type EIP1193Provider,
	custom,
	type PublicClient
} from 'viem';
import { callPublicClient } from '$lib/ts/call/call';
import { utilsError } from '../swarm/utils';
import { chainGet } from '../constants/chains';

///////////////////////////////////////////////////////////////////////////////////////////////////
// WRITE : onchain write functions via rpc, i.e. functions with walletClient
///////////////////////////////////////////////////////////////////////////////////////////////////

const _windowEthereum = (): EIP1193Provider => {
	if (!window?.ethereum)
		utilsError('_windowEthereum: Install Web3 extension like Rabby or Metamask');

	return window.ethereum!;
};

const _walletEthereum = (): WalletClient => {
	return createWalletClient({
		transport: custom(_windowEthereum())
	});
};

const sendWallet = async (chainId: number): Promise<[PublicClient, WalletClient, Address]> => {
	const publicClient = await callPublicClient(chainId);
	const walletClient = await sendWalletClient(chainId);
	const walletAddress = await sendWalletAddress(walletClient, true);

	return [publicClient, walletClient, walletAddress];
};

const sendWalletAddress = async (
	walletClient = _walletEthereum(),
	force = false,
	n = 0
): Promise<Address> => {
	return force
		? (await walletClient.requestAddresses())[n]
		: (await walletClient.getAddresses())[n];
};

const sendWalletClient = async (chainId: number): Promise<WalletClient> => {
	const ethereum = _windowEthereum();
	const chain = chainGet(chainId);

	const walletClient = createWalletClient({
		chain,
		transport: custom(ethereum)
	});

	if (chainId > 0 && chainId !== chainId) {
		console.log('sendWalletClient switchChain', chainId, chainId);
		await walletClient.switchChain({ id: chainId });
	}

	return walletClient;
};

export { sendWallet, sendWalletClient, sendWalletAddress };
