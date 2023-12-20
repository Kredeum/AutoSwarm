import 'viem/window';
import {
	createWalletClient,
	type Address,
	type WalletClient,
	type EIP1193Provider,
	custom,
	type PublicClient,
	type Transport,
	type Chain,
	type WalletClientConfig
} from 'viem';

import { callPublicClient } from '$lib/ts/call/call';
import { chainGet } from '../common/chains';

///////////////////////////////////////////////////////////////////////////////////////////////////
// WRITE : onchain write functions via rpc, i.e. functions with walletClient
///////////////////////////////////////////////////////////////////////////////////////////////////

const _windowEthereum = (): EIP1193Provider => {
	if (!window?.ethereum)
		throw new Error('windowEthereum: Install Web3 extension like Rabby or Metamask');

	return window.ethereum!;
};

const _transportEthereum = (): WalletClientConfig<Transport, Chain | undefined> => {
	return { transport: custom(_windowEthereum()) };
};

const _walletClient = (): WalletClient => createWalletClient(_transportEthereum());

// walletClients Map used as cache
const _walletClients: Map<number, WalletClient> = new Map();

const _walletClientCreate = (tbaChainId?: number): WalletClient => {
	const transportPlusOptionalChain: WalletClientConfig<Transport, Chain> = _transportEthereum();
	let walletClient: WalletClient;

	if (tbaChainId) {
		const chain = chainGet(tbaChainId);
		if (chain) transportPlusOptionalChain.chain = chain;
		walletClient = createWalletClient(transportPlusOptionalChain);

		_walletClients.set(tbaChainId, walletClient);
	} else {
		walletClient = _walletClient();
	}

	return walletClient;
};

const sendWalletClient = async (tbaChainId: number): Promise<WalletClient> => {
	// console.info('sendWalletClient ~ tbaChainId:', tbaChainId);
	const walletChainId = await sendWalletChainId();

	if (tbaChainId !== walletChainId) await sendWalletSwitchChain(tbaChainId);

	return _walletClients.get(tbaChainId) || _walletClientCreate(tbaChainId);
};

const sendWallet = async (tbaChainId: number): Promise<[PublicClient, WalletClient, Address]> => {
	const publicClient = await callPublicClient(tbaChainId);
	const walletClient = await sendWalletClient(tbaChainId);
	const walletAddress = await sendWalletAddress(true);

	return [publicClient, walletClient, walletAddress];
};

const sendWalletAddress = async (force = false, n = 0): Promise<Address> => {
	return force
		? (await _walletClient().requestAddresses())[n]
		: (await _walletClient().getAddresses())[n];
};

const sendWalletChainId = async (): Promise<number> => await _walletClient().getChainId();

const sendWalletSwitchChain = async (tbaChainId: number): Promise<void> =>
	await _walletClient().switchChain({ id: tbaChainId });

export {
	sendWallet,
	sendWalletClient,
	sendWalletAddress,
	sendWalletChainId,
	sendWalletSwitchChain
};
