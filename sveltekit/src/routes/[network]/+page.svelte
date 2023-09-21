<script lang="ts">
	import { page } from '$app/stores';
	import { goto } from '$app/navigation';
	import { onMount } from 'svelte';

	import {
		createPublicClient,
		http,
		type Address,
		type WalletClient,
		type PublicClient
	} from 'viem';
	import { gnosis, localhost, sepolia } from 'viem/chains';
	import { SECONDS_PER_BLOCK } from '$lib/ts/constants';

	import {
		displayBalance,
		displayBzzFromBalance,
		displayExplorerLink,
		displayNftLink,
		displayTtl,
		displayTxt
	} from '$lib/ts/display';
	import {
		readAccount,
		readBatchLegacy,
		readBatchNew,
		readBzzBalance,
		readLastPrice,
		readRemainingBalance
	} from '$lib/ts/read';

	import { writeTopUp } from '$lib/ts/write';
	import { ONE_YEAR } from '$lib/ts/constants';
	export let data;
	$: json = data.json;
	$: network = data.network || 'gnosis';
	let blockNumber: bigint = 0n;

	type ChainInJson = typeof gnosis | typeof sepolia | typeof localhost;
	let chain: ChainInJson = gnosis;

	let publicClient: PublicClient;
	let autoSwarmAddress: Address;

	let owner: Address;
	let depth: number;

	let lastPrice: bigint = 24000n;
	let remainingBalance: bigint;
	let normalisedBalance: bigint;
	let bzzNftBalance: bigint;
	let oneYearBzz: bigint;

	const refreshDisplay = async () => {
		console.info('refreshDisplay');
		if (!publicClient) return;


		remainingBalance = await readRemainingBalance(publicClient);
		autoSwarmAddress = await readAccount(publicClient);
		bzzNftBalance = await readBzzBalance(publicClient, autoSwarmAddress as Address);
		[owner, depth, normalisedBalance] =
    chain.id == 100 ? await readBatchLegacy(publicClient) : await readBatchNew(publicClient);

		const lastPriceRead = await readLastPrice(publicClient);
    if (lastPriceRead >0 ) lastPrice = lastPriceRead;
		oneYearBzz = (lastPrice * BigInt(ONE_YEAR)) / SECONDS_PER_BLOCK;
	};

	const topUp = async () => {
		console.info('topUp');

		let walletClient: WalletClient;
		await writeTopUp(chain, publicClient);
		await refreshDisplay();
	};

	const initChain = async (nw: string): Promise<void> => {
		console.info('initChain <-', nw);

		let transport = http();
		if (nw == 'sepolia') {
			chain = sepolia;
			transport = http('https://eth-sepolia-public.unifra.io');
		} else if (nw == 'localhost') {
			chain = localhost;
		} else {
			chain = gnosis;
		}
		console.info('createPublicClient');
		publicClient = createPublicClient({ chain, transport });

		publicClient.watchBlockNumber({
			emitOnBegin: true,
			onBlockNumber: (num: bigint) => (blockNumber = num)
		});

		await refreshDisplay();

		console.info('initChain ->', chain);
	};

	const onChainChanged = (chainId: string): void => {
		console.log('onChainChanged', chainId);

		let next = 'gnosis';
		if (chainId == '11155111') next = 'sepolia';
		else if (chainId == '1337') next = 'localhost';

		goto(next).then(() => initChain(next));
	};

	onMount(async () => {
		console.info('onMount');
		await initChain(network);
	});
</script>

<section>
	<p>
		Block {network} ({chain.id}) <span> #{blockNumber}</span>
	</p>
	<p>
		PostageStamp <span>{@html displayExplorerLink(chain, json.PostageStamp)}</span>
	</p>
	<p>
		BzzToken <span>{@html displayExplorerLink(chain, json.BzzToken)}</span>
	</p>
	<p>
		ERC6551 Registry <span>{@html displayExplorerLink(chain, json.ERC6551Registry)}</span>
	</p>
	<p>
		NFT <span>{@html displayNftLink(chain, json.NFTCollection, Number(json.tokenId))}</span>
	</p>
	<p>
		NFT SmartAccount <span
			>{displayBalance(bzzNftBalance, 16, 4)} Bzz | {@html displayExplorerLink(
				chain,
				autoSwarmAddress
			)}</span
		>
	</p>
	<p>
		BatchId <span>{json.batchId}</span>
	</p>
	<p>
		Batch <span
			>[{@html displayExplorerLink(chain, owner)}, {displayTxt(depth)}, {displayTxt(
				remainingBalance
			)}]</span
		>
	</p>
	<p>
		Batch LifeSpan
		<span
			>{displayBzzFromBalance(remainingBalance, depth)} Bzz | {displayTtl(
				remainingBalance,
				lastPrice
			)}</span
		>
	</p>
	<p>
		One Year TopUp <span
			>{displayBzzFromBalance(oneYearBzz, depth)} Bzz | {displayTtl(oneYearBzz, lastPrice)}</span
		>
	</p>
	<p>
		<button on:click={topUp}>TopUp</button>
		<span>
			{#if network != 'gnosis'}
				<button on:click={() => onChainChanged('100')}>gnosis</button>
			{/if}
			{#if network != 'sepolia'}
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
