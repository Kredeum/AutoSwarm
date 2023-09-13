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
	let publicClient: PublicClient;
	let walletClient: WalletClient;
	let bzzToken: GetContractReturnType;
	let postageStamp: GetContractReturnType;

	const gnosisExplorer = 'https://gnosisscan.io/address';

	let blockNumber: bigint = 0n;
	let bal: bigint = 0n;
	let balj: number = 0;

	let owner: Address = '0x0';
	let depth: number = 17;
	let immutable: boolean = false;
	let rBal: bigint = 0n;
	let rBalj: number = 0;
	let bzz0: bigint = 0n;
	let bzzAmount0: string = '';
	let bzz: bigint = 0n;
	let bzzAmount: string = '';
	let bzzOwnerAmount = '';
	const lastPrice = 24000;
	const oneDay = 24 * 3600;
	const dv = BigInt(lastPrice * oneDay);

	let walletAddress: Address = '0x0';
	let walletAddressAmount: string = '';

	const explorerLink = (addr: string): string => {
		return `<a href="${gnosisExplorer}/${addr}" target="_blank">${addr}</a>`;
	};

	const topUp = async () => {
		console.log('topUp');

		let topUpttl: bigint = 1000n;
		let topUpBzz: bigint = topUpttl * 2n ** 17n;

		const hash1 = await bzzToken.write.approve([json.PostageStamp as Hex, topUpBzz]);
		await publicClient.waitForTransactionReceipt({ hash: hash1 });

		const hash2 = await postageStamp.write.topUp([json.batchId as Hex, topUpttl]);
		await publicClient.waitForTransactionReceipt({ hash: hash2 });
	};

	onMount(async () => {
		publicClient = createPublicClient({
			chain,
			transport: http()
		});
		walletClient = createWalletClient({
      account: "0x981ab0d817710d8fffc5693383c00d985a3bda38",
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

		[owner, depth, immutable, rBal] = await postageStamp.read.batches([json.batchId as Hex]);
		bzz = rBal * 2n ** BigInt(depth);
		bzzAmount = formatUnits(bzz, 16);
		bzzOwnerAmount = formatUnits(await bzzToken.read.balanceOf([owner as Hex]), 16);

		bal = await postageStamp.read.remainingBalance([json.batchId as Hex]);
		bzz0 = bal * 2n ** BigInt(depth);
		bzzAmount0 = formatUnits(bzz0, 16);

		balj = Number(bal / dv);
		rBalj = Number(rBal / dv);

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
		BatchId <span>{json.batchId}</span>
	</p>
	<p>
		Batch <span>[{@html explorerLink(owner)}, {depth}, {immutable}, {rBal}]</span>
	</p>
	<p>
		Batch creating Balance <span>{bzzAmount} Bzz | {rBalj} jours</span>
	</p>
	<p>
		Batch remaining Balance <span>{bzzAmount0} Bzz | {balj} jours</span>
	</p>
	<p>
		Owner <span>{bzzOwnerAmount} Bzz | {@html explorerLink(owner)}</span>
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
