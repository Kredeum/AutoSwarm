<script lang="ts">
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';

	import { gnosis, localhost, sepolia, thunderTestnet } from 'viem/chains';
	import { createPublicClient, http, type Address, type PublicClient } from 'viem';

	import { anvil } from '$lib/ts/anvil';
	import {
		SECONDS_PER_BLOCK,
		ONE_YEAR,
		DEFAULT_PRICE,
		ONE_MONTH,
		ONE_DAY
	} from '$lib/ts/constants';
	import {
		writeStampsBuy,
		writeStampsDeposit,
		writeStampsIncreaseDepth,
		writeStampsTopUp,
		writeStampsWithdraw
	} from '$lib/ts/writeStamps.js';
	import {
		readAccount,
		readBatchLegacy,
		readBatchNew,
		readBzzBalance,
		readIsContract,
		readLastPrice,
		readLastTokenId,
		readNftOwner,
		readRemainingBalance
	} from '$lib/ts/read';
	import {
		displayBalance,
		displayBzzFromBalance,
		displayDuration,
		displayExplorerLink,
		displayNftLink,
		displayTbaDisplayed,
		displayTtl,
		displayTxt
	} from '$lib/ts/display';
	import { utilsNBalToTtl, utilsBzzToNBal } from '$lib/ts/utils.js';
	import { stampBzzToTtl } from '$lib/ts/stamp.js';

	export let data;

	$: json = data.json;
	$: network = data.network || 'gnosis';

	let blockNumber: bigint = 0n;

	type ChainInJson = typeof gnosis | typeof sepolia | typeof anvil | typeof localhost;
	let chain: ChainInJson = gnosis;

	let publicClient: PublicClient;

	let autoSwarmAddress: Address | undefined;
	let owner: Address | undefined;
	let nftOwner: Address | undefined;
	let depth: number;
	let unwatch: () => void;

	let lastPrice: bigint = DEFAULT_PRICE;
	let remainingBalance: bigint | undefined;
	let normalisedBalance: bigint | undefined;
	let bzzNftBalance: bigint | undefined;
	let bzzNftOwnerBalance: bigint | undefined;
	let oneDayBzz: bigint | undefined;
	let tbaDeployed: boolean | undefined;
	let tokenId = 1n;

	const reset = () => {
		lastPrice = DEFAULT_PRICE;
		remainingBalance = undefined;
		normalisedBalance = undefined;
		bzzNftBalance = undefined;
		bzzNftOwnerBalance = undefined;
		oneDayBzz = undefined;
		autoSwarmAddress = undefined;
		owner = undefined;
		nftOwner = undefined;
		tbaDeployed = undefined;
	};

	const refreshDisplay = async () => {
		console.info('refreshDisplay');
		if (!publicClient) return;
		reset();

		tokenId = await readLastTokenId(publicClient);
		nftOwner = await readNftOwner(publicClient);
		bzzNftOwnerBalance = await readBzzBalance(publicClient, nftOwner);
		autoSwarmAddress = await readAccount(publicClient);
		bzzNftBalance = await readBzzBalance(publicClient, autoSwarmAddress);

		remainingBalance = await readRemainingBalance(publicClient);
		[owner, depth, normalisedBalance] =
			chain.id == 100 ? await readBatchLegacy(publicClient) : await readBatchNew(publicClient);

		const lastPriceRead = await readLastPrice(publicClient);
		if (lastPriceRead > 0) lastPrice = lastPriceRead;
		oneDayBzz = (lastPrice * BigInt(ONE_DAY)) / SECONDS_PER_BLOCK;

		tbaDeployed = await readIsContract(publicClient, autoSwarmAddress as Address);
		console.log('refreshDisplay ~ tbaDeployed:', tbaDeployed);
	};

	const buy = () => writeStampsBuy(chain, publicClient).then(refreshDisplay);
	const withdraw = () => writeStampsWithdraw(chain, publicClient).then(refreshDisplay);
	const deposit = () => writeStampsDeposit(chain, publicClient).then(refreshDisplay);
	const dilute = () =>
		writeStampsIncreaseDepth(chain, publicClient, depth + 2).then(refreshDisplay);

	const topUp = (months: number) =>
		writeStampsTopUp(
			chain,
			publicClient,
			(BigInt(months * ONE_DAY) * lastPrice) / SECONDS_PER_BLOCK
		).then(refreshDisplay);

	const initChain = async (nw: string): Promise<void> => {
		console.info('initChain <-', nw);

		let transport = http();
		if (nw == 'sepolia') {
			chain = sepolia;
			transport = http('https://rpc.ankr.com/eth_sepolia');
		} else if (nw == 'localhost') {
			chain = localhost;
		} else if (nw == 'anvil') {
			chain = anvil;
		} else {
			chain = gnosis;
		}
		publicClient = createPublicClient({ chain, transport });
		if (unwatch) unwatch();
		unwatch = publicClient.watchBlockNumber({
			emitOnBegin: true,
			onBlockNumber: (num: bigint) => (blockNumber = num)
		});

		await refreshDisplay();

		console.info('initChain ->', chain);
	};

	const onChainChanged = (chainId: string): void => {
		let next = 'gnosis';
		if (chainId == '11155111') next = 'sepolia';
		else if (chainId == '31337') next = 'anvil';
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
		{chain.name} network (chainId #{chain.id}) <span>block #{blockNumber}</span>
	</p>
	<p>
		NFT <span>
			{@html displayExplorerLink(chain)} /
			{@html displayExplorerLink(chain, json.NFTCollection)} /
			{@html displayNftLink(chain, json.NFTCollection, Number(tokenId))}
		</span>
	</p>
	<p>
		NFT AutoSwarm TBA ({displayTbaDisplayed(tbaDeployed)})
		<span
			>{displayBalance(bzzNftBalance, 16, 4)} Bzz | {@html displayExplorerLink(
				chain,
				autoSwarmAddress
			)}</span
		>
	</p>
	<p>
		NFT Owner<span> {@html displayExplorerLink(chain, nftOwner)}</span>
	</p>
	<hr />
	<p>
		<button on:click={withdraw}>Withdraw</button> &nbsp;
		<button on:click={deposit}>Deposit</button> &nbsp;
		<button on:click={dilute}>Dilute</button> &nbsp;
		<button on:click={buy}>Buy</button> &nbsp;
		<span>
			<button title="Cost {displayBzzFromBalance(oneDayBzz, depth)} Bzz" on:click={() => topUp(1)}
				>TopUp 1 Day</button
			>
			<button
				title="Cost {displayBzzFromBalance(oneDayBzz && oneDayBzz * 7n, depth)} Bzz"
				on:click={() => topUp(7)}>TopUp 1 Week</button
			>
			<button
				title="Cost {displayBzzFromBalance(oneDayBzz && oneDayBzz * 30n, depth)} Bzz"
				on:click={() => topUp(30)}>TopUp 1 Month</button
			>
			<button
				title="Cost {displayBzzFromBalance(oneDayBzz && oneDayBzz * 365n, depth)} Bzz"
				on:click={() => topUp(365)}>TopUp 1 Year</button
			>
		</span>
	</p>
	<p>PostageStamp Last Price (1 Plur=1e-16 Bzz) <span>{lastPrice} Plur/block</span></p>
	<p>Expiration Date</p>
	<p>Total Ttl</p>
	<p>
		Bzz Ttl <span
			>{displayDuration(stampBzzToTtl(bzzNftBalance || 0n, lastPrice, BigInt(10_000)))}</span
		>
	</p>
	<p>Stamp/Batch Ttl</p>
	<p>Current Stamp</p>
	<p>Current Batch</p>

	<p>
		<button><a href="/">back</a></button> &nbsp;
		<button on:click={refreshDisplay}>refresh</button> &nbsp;
		<span>
			<!-- <button on:click={() => onChainChanged('100')}>go gnosis</button> -->
			<button on:click={() => onChainChanged('11155111')}>go sepolia</button>
			<button on:click={() => onChainChanged('31337')}>go anvil</button>
		</span>
	</p>

	<hr />
	<p>
		Batch Remaining LifeSpan
		<span
			>{displayBzzFromBalance(remainingBalance, depth)} Bzz |
			{displayTtl(remainingBalance, lastPrice)} | depth {depth}</span
		>
	</p>
	<p>
		One Year TopUp at price {lastPrice}<span
			>{displayBzzFromBalance(oneDayBzz && oneDayBzz * 365n, depth)} Bzz | {displayTtl(
				oneDayBzz && oneDayBzz * 365n,
				lastPrice
			)} | depth
			{depth}</span
		>
	</p>

	<p>
		Batch <span
			>[{@html displayExplorerLink(chain, owner)}, {displayTxt(depth)}, {displayTxt(
				remainingBalance
			)}, {displayTxt(normalisedBalance)}]</span
		>
	</p>
	<p>
		Batch Id <span>{json.batchId}</span>
	</p>
	<hr />
	<p>
		PostageStamp <span>{@html displayExplorerLink(chain, json.PostageStamp)}</span>
	</p>
	<p>
		BzzToken <span>{@html displayExplorerLink(chain, json.BzzToken)}</span>
	</p>
	<p>
		AutoSwarm implementation <span>{@html displayExplorerLink(chain, json.AutoSwarmAccount)}</span>
	</p>
	<p>
		ERC6551 Registry <span>{@html displayExplorerLink(chain, json.ERC6551Registry)}</span>
	</p>
	<p>
		Price Oracle <span>{@html displayExplorerLink(chain, json.Oracle)}</span>
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
