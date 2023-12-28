import { type Address, zeroAddress, type Hex } from 'viem';
import { autoSwarmAccountAbi } from '$lib/ts/constants/abis';
import { sendWallet } from './send';
import { ZERO_BYTES32 } from '../constants/constants';

const sendTbaCreateStamp = async (
	bzzChainId: number,
	tba: Address,
	beeHash = ZERO_BYTES32 as Hex,
	nftSize: bigint,
	bzzAmount: bigint
) => {
	console.info('sendTbaCreateStamp:', bzzChainId, tba, beeHash, nftSize);

	if (!(bzzChainId > 0)) throw new Error('Bad chain!');
	if (!tba) throw new Error('No TBA!');
	if (!nftSize) throw new Error('No Swarm Size!');
	if (!beeHash) throw new Error('No Swarm Hash!');

	const [publicClient, walletClient, walletAddress] = await sendWallet(bzzChainId);

	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: tba,
		abi: autoSwarmAccountAbi,
		functionName: 'createStamp',
		args: [beeHash, nftSize, bzzAmount]
	});

	const hash = await walletClient.writeContract(request);
	await publicClient.waitForTransactionReceipt({ hash });
};

const sendTbaSetAutoSwarmStamp = async (
	bzzChainId: number,
	tba: Address | undefined,
	beeHash: Hex | undefined,
	nftSize: bigint | undefined,
	bzzAmount: bigint | undefined
) => {
	console.info('sendTbaSetAutoSwarmStamp:', bzzChainId, tba, beeHash, nftSize, bzzAmount);

	if (!(bzzChainId > 0)) throw new Error('Bad chain!');
	if (!tba) throw new Error('No TBA!');
	if (!beeHash) throw new Error('No Swarm Hash!');
	if (!nftSize) throw new Error('No Swarm Size!');
	if (!bzzAmount) throw new Error('No BZZ!');

	const [publicClient, walletClient, walletAddress] = await sendWallet(bzzChainId);

	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: tba,
		abi: autoSwarmAccountAbi,
		functionName: 'setAutoSwarmStamp',
		args: [nftSize, beeHash, bzzAmount]
	});

	const hash = await walletClient.writeContract(request);
	await publicClient.waitForTransactionReceipt({ hash });
};

const sendTbaTopUp = async (bzzChainId: number, tba: Address | undefined, bzzAmount: bigint) => {
	if (!(bzzChainId > 0)) throw new Error('Bad chain!');
	if (!tba) throw new Error('Bad TBA!');

	const [publicClient, walletClient, walletAddress] = await sendWallet(bzzChainId);

	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: tba,
		abi: autoSwarmAccountAbi,
		functionName: 'topUp',
		args: [bzzAmount]
	});
	const hash = await walletClient.writeContract(request);
	await publicClient.waitForTransactionReceipt({ hash });
};

const sendTbaWithdraw = async (bzzChainId: number, tba: Address, token = zeroAddress) => {
	if (!(bzzChainId > 0 && tba)) throw new Error('sendTbaWithdraw: No tba');

	const [publicClient, walletClient, walletAddress] = await sendWallet(bzzChainId);

	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: tba,
		abi: autoSwarmAccountAbi,
		functionName: 'withdraw',
		args: [token]
	});
	const hash = await walletClient.writeContract(request);
	await publicClient.waitForTransactionReceipt({ hash });
};

export { sendTbaTopUp, sendTbaWithdraw, sendTbaCreateStamp, sendTbaSetAutoSwarmStamp };
