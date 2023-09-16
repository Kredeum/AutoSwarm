<script lang="ts">
	import type { NftMetadata } from '$lib/types/types';

	import {
		createPublicClient,
		createWalletClient,
		http,
		custom,
		getContract,
		parseAbi,
		type Hex,
		type Address,
		type WalletClient,
		type GetContractReturnType,
		type PublicClient,
		type Abi
	} from 'viem';
	import { gnosis, sepolia } from 'viem/chains';

	import 'viem/window';

	import { onMount } from 'svelte';

	import jsonFile from '../../../addresses.json';
	import { abi } from '$lib/abis/postagStamp.json';

	const chain = gnosis;
	const json = jsonFile[chain.id];

	const bzzTokenStampAbi = parseAbi([
		'function balanceOf(address) external view returns(uint256)',
		'function approve(address,uint256) public returns (bool)'
	]);

	// const postageStampAbi = parseAbi([
	// 	'function remainingBalance(bytes32) external view returns(uint256)',
	// 	'function batches(bytes32) external view returns(address,uint8,bool,uint256)',
	// 	'function topUp(bytes32, uint256) external',
	// ]);

	const postageStampAbi = abi as Abi;
	console.log('postageStampAbi:', postageStampAbi);

	let batchId: Hex = json.batchId1 as Hex;

	let publicClient: PublicClient;
	let walletClient: WalletClient;

	let account: Hex;
	let chainId: number;

	let collection: string;
	let tokenID: string = '1';
	let nftMetadatasUrl: string =
		'https://api.gateway.ethswarm.org/bzz/50e464a94da781c5b8f5b3ce46a948810bfce9bc879a19fc46197ee9b88a7046/';
	let nftMetadatas: NftMetadata;

	let bzzToken: GetContractReturnType;
	let postageStamp: GetContractReturnType;

	const gnosisExplorer = 'https://gnosisscan.io/address';

	let bal: number = 0;

	let owner: Address = '0x0';
	let depth: number = 17;
	let immutable: boolean = false;
	let rBal: bigint = 0n;
	let lastPrice: number = 24000;

	const oneHour = 60 * 60;
	const oneDay = oneHour * 24;
	const oneWeek = oneDay * 7;
	const oneMonth = oneDay * 30;
	const oneYear = oneDay * 365;
	const secondsPerBlock = 5;

	let topping = false;

	$: console.log('account switch', account);
	$: console.log('chainId switch', chainId);
	$: console.log('NFT metadatas', nftMetadatas);

	onMount(async () => {
		if (typeof window.ethereum !== 'undefined') {
			publicClient = createPublicClient({
				chain,
				transport: http()
			});

			walletClient = createWalletClient({
				transport: custom(window.ethereum)
			});

			account = await getAddress();
			chainId = await publicClient.getChainId();
			nftMetadatas = await metadataGet();

			walletClient = createWalletClient({
				chain,
				account,
				transport: custom(window.ethereum)
			});

			// window.ethereum.on('accountsChanged', (_accounts: string[]) => {
			// 	console.log('🚀 ~ file: +page.svelte:29 ~ window.ethereum.on ~ _accounts:', _accounts);
			// 	account = _accounts[0] as Hex;
			// });

			// window.ethereum.on('chainChanged', (_chainId: string) => {
			// 	console.log('🚀 ~ file: +page.svelte:33 ~ window.ethereum.on ~ _chainId:', _chainId);
			// 	chainId = parseInt(_chainId, 16);
			// 	console.log(
			// 		'🚀 ~ file: +page.svelte:34 ~ window.ethereum.on ~ _chainId.toString():',
			// 		parseInt(_chainId, 16)
			// 	);
			// });

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
		}

		lastPrice = Number(await postageStamp.read.lastPrice());
		console.log('onMount ~ lastPrice:', lastPrice);

		[owner, depth, immutable, rBal] = await postageStamp.read.batches([json.batchId as Hex]);

		await updateRemainingBal();
		console.log('updateRemainingBal ~ bal:', bal);

		const unwatch = publicClient.watchContractEvent({
			address: json.PostageStamp as Address,
			abi: postageStampAbi,
			eventName: 'BatchTopUp',
			args: { batchId: batchId },
			onLogs: (logs) => {
				console.log('BatchTopUp event : ', logs);
				updateRemainingBal();
			}
		});

		console.log('onMount ended');
	});

	const updateRemainingBal = async () => {
		bal = Number(await postageStamp.read.remainingBalance([batchId]));
	};

	const topUp = async () => {
		console.log('topUp');

		// Add 1h
		let topUpttl: bigint = (24000n / 5n) * 3600n;

		// Add 10 days
		// let topUpttl: bigint = (24000n / 5n) * 3600n * 24n * 10n;
		let topUpBzz: bigint = topUpttl * 2n ** BigInt(depth);
		console.log('topUp ~ topUpBzz:', topUpBzz);

		const hash1 = await bzzToken.write.approve([json.PostageStamp as Hex, topUpBzz]);
		topping = true;
		await publicClient.waitForTransactionReceipt({ hash: hash1 });

		const hash2 = await postageStamp.write.topUp([batchId, topUpttl]);
		await publicClient.waitForTransactionReceipt({ hash: hash2 });
		topping = false;
	};

	const displayDuration = (duration: number = 0) => {
		let remainder = 0;
		let resultString = '';

		const durationBase = (duration * secondsPerBlock) / lastPrice;

		let years = durationBase / oneYear;
		remainder = durationBase % oneYear;
		years = Math.floor(years);
		resultString = years ? `${years} year | ` : '';

		let months = remainder / oneMonth;
		remainder = remainder % oneMonth;
		months = Math.floor(months);
		resultString += months ? `${months} months | ` : '';

		let weeks = remainder / oneWeek;
		remainder = remainder % oneWeek;
		weeks = Math.floor(weeks);
		resultString += weeks ? `${weeks} weeks | ` : '';

		let days = remainder / oneDay;
		remainder = remainder % oneDay;
		days = Math.floor(days);
		resultString += days ? `${days} days | ` : '';

		let hours = (remainder / oneHour).toFixed(1);
		resultString += hours ? `${hours} hours` : '';

		return resultString;
	};

	// NFT
	const metadataGet = async () => {
		const response = await fetch(nftMetadatasUrl);
		const jsonData = await response.json();
		console.log(jsonData);

		return jsonData;
	};

	// VIEM
	const getAddress = async () => {
		const addresses = await walletClient.getAddresses();
		console.log('addresses:', addresses);
		console.log('address current:', addresses[0]);
		return addresses[0];
	};

	const connectMetamask = async () => {
		if (typeof window.ethereum !== 'undefined') {
			[account] = await window.ethereum.request({ method: 'eth_requestAccounts' });
		}
	};
</script>

{#if !account}
	<section class="user-config">
		<button class="btn-connect" on:click={connectMetamask}>
			Connect your Metamask and choose your files
		</button>
	</section>
{:else}
	<section>
		<div class="nfts-grid">
			{#if account && nftMetadatas}
				<article>
					<div
						class="nft-img"
						style="background-image: url({nftMetadatas.image});"
						aria-label={nftMetadatas.description}
					/>
					<p>{nftMetadatas.name} <span># {tokenID}</span></p>
					<i class="fa-solid fa-user" />
					<i class="fa-solid fa-spinner fa-spin-pulse" />
				</article>
			{/if}
		</div>
		<div class="nfts-info">
			<p class="">Remaining TTL : {displayDuration(bal)}</p>
		</div>
		<div class="buttons">
			<button class="btn btn-topup" on:click={topUp}>
				TopUp
				{#if topping}
					<i class="fa-solid fa-spinner fa-spin-pulse" />
				{/if}
			</button>
			<a class="btn btn-light" href="./auto">Details ></a>
		</div>
	</section>
{/if}
