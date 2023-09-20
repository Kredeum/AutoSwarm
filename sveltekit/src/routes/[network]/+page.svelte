<script lang="ts">
	export let data;

	import { goto } from '$app/navigation';
	import { onMount } from 'svelte';
	import {
		createPublicClient,
		createWalletClient,
		http,
		custom,
		type Address,
		formatUnits,
		type WalletClient,
		type PublicClient,
		publicActions
	} from 'viem';
	import { gnosis, localhost, sepolia } from 'viem/chains';

	import { getDisplayDuration, getExplorerLink, getJson, type ChainIdInJson } from '$lib/ts/get';
	import {
		readAccount,
		readBatchLegacy,
		readBatchNew,
		readBzzBalance,
		readRemainingBalance
	} from '$lib/ts/read';
	import { writeTopUp } from '$lib/ts/write';

	type ChainInJson = typeof gnosis | typeof sepolia | typeof localhost;

	let chain: ChainInJson = gnosis;

	let publicClient: PublicClient;
	let walletClient: WalletClient;
	let autoSwarmAddress: Address = '0x0';

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

	const refreshDisplay = async () => {
		console.info('refreshDisplay');
		if (!publicClient) return;

		[owner, depth, rBal] =
			chain.id == 100 ? await readBatchLegacy(publicClient) : await readBatchNew(publicClient);

		bzz = rBal * 2n ** BigInt(depth);
		bzzAmount = formatUnits(bzz, 16);
		bzzOwnerAmount = formatUnits(await readBzzBalance(publicClient, owner as Address), 16);

		bal = await readRemainingBalance(publicClient);

		bzz0 = bal * 2n ** BigInt(depth);
		bzzAmount0 = formatUnits(bzz0, 16);

		balh = Number(bal) / dv;
		rBalh = Number(rBal) / dv;

		autoSwarmAddress = await readAccount(publicClient);
	};

	const topUp = async () => {
		console.info('topUp');

		await writeTopUp(publicClient, walletClient);
		await refreshDisplay();
	};

	const initChain = async (): Promise<void> => {
		console.info('initChain');

		let transport = http();
		if (data.network == 'sepolia') {
			chain = sepolia;
			transport = http('https://eth-sepolia-public.unifra.io');
		} else if (data.network == 'localhost') {
			chain = localhost;
		} else {
			chain = gnosis;
		}
		console.info('createPublicClient');
		publicClient = createPublicClient({ chain, transport });

		if (window.ethereum) {
			console.info('createWalletClient');
			walletClient = createWalletClient({
				chain,
				transport: custom(window.ethereum!)
			}).extend(publicActions);
		}

		await refreshDisplay();
	};

	const onChainChanged = (chainId: string): void => {
		console.log('onChainChanged', chainId);

		let next = 'gnosis';
		if (chainId == '11155111') next = 'sepolia';
		else if (chainId == '1337') next = 'localhost';

		goto(next).then(initChain);
	};

	onMount(async () => {
		console.info('onMount');

		await initChain();

		if (window.ethereum) {
			window.ethereum.on('chainChanged', onChainChanged);
		} else {
			alert('Install web3 extension like Rabby or Metamask');
		}

		publicClient.watchBlockNumber({
			emitOnBegin: true,
			onBlockNumber: (num: bigint) => (blockNumber = num)
		});

		console.info('onMount end');
	});
</script>

<section>
	<p>
		Block {chain.network} ({chain.id}) <span> #{blockNumber}</span>
	</p>
	<p>
		PostageStamp <span>{@html getExplorerLink(chain, data.json.PostageStamp)}</span>
	</p>
	<p>
		BzzToken <span>{@html getExplorerLink(chain, data.json.BzzToken)}</span>
	</p>
	<p>
		BatchId <span>{data.json.batchId}</span>
	</p>
	<p>
		Batch <span>[{@html getExplorerLink(chain, owner)}, {depth}, {immutable}, {rBal}]</span>
	</p>
	<p>
		Batch creating Balance
		<span>{bzzAmount} Bzz | {getDisplayDuration(rBalh)}</span>
	</p>
	<p>
		Batch remaining Balance <span>{bzzAmount0} Bzz | {getDisplayDuration(balh)}</span>
	</p>
	<p>
		Owner <span>{bzzOwnerAmount} Bzz | {@html getExplorerLink(chain, owner)}</span>
	</p>
	<p>
		NFT SmartAccount <span> {@html getExplorerLink(chain, autoSwarmAddress)}</span>
	</p>
	<p>
		<button on:click={topUp}>TopUp</button>
		<span>
			{#if data.network != 'gnosis'}
				<button on:click={() => onChainChanged('100')}>gnosis</button>
			{/if}
			{#if data.network != 'sepolia'}
				<button on:click={() => onChainChanged('11155111')}>sepolia</button>
			{/if}
			<button><a href="..">back</a></button>
		</span>
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
