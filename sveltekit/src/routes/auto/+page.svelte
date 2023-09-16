<script lang="ts">
	import {
		createPublicClient,
		createWalletClient,
		http,
		custom,
		getContract,
		parseAbi,
		type Hex,
		type Address,
		formatUnits,
		type WalletClient,
		type GetContractReturnType,
		type PublicClient
	} from 'viem';
	import { gnosis, sepolia } from 'viem/chains';
	import { onMount } from 'svelte';
	import jsonFile from '../../../../addresses.json';

	const chain = gnosis;
	const json = jsonFile[chain.id];

	const bzzTokenStampAbi = parseAbi([
		'function balanceOf(address) external view returns(uint256)',
		'function approve(address,uint256) public returns (bool)'
	]);

	const postageStampAbi = parseAbi([
		'function remainingBalance(bytes32) external view returns(uint256)',
		'function batches(bytes32) external view returns(address,uint8,bool,uint256)',
		'function topUp(bytes32, uint256) external'
	]);

	let batchId: Hex = json.batchId as Hex;

	let publicClient: PublicClient;
	let walletClient: WalletClient;
	let bzzToken: GetContractReturnType;
	let postageStamp: GetContractReturnType;

	const gnosisExplorer = 'https://gnosisscan.io/address';

	let blockNumber: bigint = 0n;
	let bal: bigint = 0n;
	let balh: number = 0;

	let owner: Address = '0x0';
	let depth: number = 17;
	let immutable: boolean = false;
	let rBal: bigint = 0n;
	let rBalh: number = 0;
	let bzz0: bigint = 0n;
	let bzzAmount0: string = '';
	let bzz: bigint = 0n;
	let bzzAmount: string = '';
	let bzzOwnerAmount = '';
	const lastPrice = 24000;
	const oneHour = 60 * 60;
	const secondsPerBlock = 5;
	const dv = (lastPrice * oneHour) / secondsPerBlock;

	let walletAddress: Address = '0x0';
	let walletAddressAmount: string = '';

	const explorerLink = (addr: string): string => {
		return `<a href="${gnosisExplorer}/${addr}" target="_blank">${addr}</a>`;
	};

	const topUp = async () => {
		console.log('topUp');

		let topUpttl: bigint = (24000n / 5n) * 3600n;
		let topUpBzz: bigint = topUpttl * 2n ** 17n;

		const hash1 = await bzzToken.write.approve([json.PostageStamp as Hex, topUpBzz]);
		await publicClient.waitForTransactionReceipt({ hash: hash1 });

		const hash2 = await postageStamp.write.topUp([batchId, topUpttl]);
		await publicClient.waitForTransactionReceipt({ hash: hash2 });
	};

	const displayDuration = (duration: number = 0) => {
		const hours = duration;
		const days = duration / 24;
		const weeks = duration / (24 * 7);
		const months = duration / (24 * 30);
		const years = duration / (24 * 365);

		return hours < 24
			? `${hours.toFixed(1)} hours`
			: days < 7
			? `${days.toFixed(1)} days`
			: weeks < 5
			? `${weeks.toFixed(1)} weeks`
			: months < 12
			? `${months.toFixed(1)} months`
			: `${years.toFixed(1)} years`;
	};

	onMount(async () => {
		publicClient = createPublicClient({
			chain,
			transport: http()
		});
		walletClient = createWalletClient({
			account: '0x981ab0d817710d8fffc5693383c00d985a3bda38',
			chain,
			transport: custom(window.ethereum!)
		});

		postageStamp = getContract({
			address: json.PostageStamp as Address,
			abi: postageStampAbi,
			publicClient,
			walletClient
		});
		bzzToken = getContract({
			address: json.BzzToken as Address,
			abi: bzzTokenStampAbi,
			publicClient,
			walletClient
		});

		publicClient.watchBlockNumber({
			emitOnBegin: true,
			onBlockNumber: (num: bigint) => (blockNumber = num)
		});

		[owner, depth, immutable, rBal] = await postageStamp.read.batches([batchId]);
		bzz = rBal * 2n ** BigInt(depth);
		bzzAmount = formatUnits(bzz, 16);
		bzzOwnerAmount = formatUnits(await bzzToken.read.balanceOf([owner as Hex]), 16);

		bal = await postageStamp.read.remainingBalance([batchId]);
		bzz0 = bal * 2n ** BigInt(depth);
		bzzAmount0 = formatUnits(bzz0, 16);

		balh = Number(bal) / dv;
		rBalh = Number(rBal) / dv;

		[walletAddress] = await walletClient.requestAddresses();
		walletAddressAmount = formatUnits(await bzzToken.read.balanceOf([walletAddress as Hex]), 16);

		console.log('onMount ended');
	});
</script>

<section>
	<p>
		Block {chain.network} ({chain.id}) <span> #{blockNumber}</span>
	</p>
	<p>
		PostageStamp <span>{@html explorerLink(json.PostageStamp)}</span>
	</p>
	<p>
		BzzToken <span>{@html explorerLink(json.BzzToken)}</span>
	</p>
	<p>
		batchId <span>{batchId}</span>
	</p>
	<p>
		Batch <span>[{@html explorerLink(owner)}, {depth}, {immutable}, {rBal}]</span>
	</p>
	<p>
		Batch creating Balance <span>{bzzAmount} Bzz | {displayDuration(rBalh)}</span>
	</p>
	<p>
		Batch remaining Balance <span>{bzzAmount0} Bzz | {displayDuration(balh)}</span>
	</p>
	<p>
		Node Owner <span>{bzzOwnerAmount} Bzz | {@html explorerLink(owner)}</span>
	</p>
	<p>
		Wallet <span>{walletAddressAmount} Bzz | {@html explorerLink(walletAddress)}</span>
	</p>
	<p>
		<button on:click={topUp}>TopUp</button>
		<span><button><a href="..">Back</a></button></span>
	</p>
</section>

<style>
	section {
		width: 800px;
		display: block;
		text-align: left;
	}
	section p span {
		float: right;
	}
</style>
