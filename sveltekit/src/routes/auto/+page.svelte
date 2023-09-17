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

	const refresh = async () => {
		[owner, depth, immutable, rBal] = await postageStamp.read.batches([json.batchId as Hex]);
		bzz = rBal * 2n ** BigInt(depth);
		bzzAmount = formatUnits(bzz, 16);
		bzzOwnerAmount = formatUnits(await bzzToken.read.balanceOf([owner as Address]), 16);

		bal = await postageStamp.read.remainingBalance([json.batchId as Hex]);
		bzz0 = bal * 2n ** BigInt(depth);
		bzzAmount0 = formatUnits(bzz0, 16);

		balh = Number(bal) / dv;
		rBalh = Number(rBal) / dv;

		[walletAddress] = await walletClient.requestAddresses();
		walletAddressAmount = formatUnits(
			await bzzToken.read.balanceOf([walletAddress as Address]),
			16
		);
	};

	const topUp = async () => {
		console.log('topUp');

		let topUpttl: bigint = (24000n / 5n) * 3600n;
		let topUpBzz: bigint = topUpttl * 2n ** 17n;

		// const hash1 = await bzzToken.write.approve([json.PostageStamp as Address, topUpBzz]);
		const { request: request1 } = await publicClient.simulateContract({
			account: walletAddress,
			address: json.BzzToken as Address,
			abi: bzzTokenStampAbi,
			functionName: 'approve',
			args: [json.PostageStamp as Address, topUpBzz]
		});
		const hash1 = await walletClient.writeContract(request1);
		await publicClient.waitForTransactionReceipt({ hash: hash1 });

		// const hash2 = await postageStamp.write.topUp([json.batchId as Address, topUpttl]);
		const { request: request2 } = await publicClient.simulateContract({
			account: walletAddress,
			address: json.PostageStamp as Address,
			abi: postageStampAbi,
			functionName: 'topUp',
			args: [json.batchId as Hex, topUpttl]
		});
		const hash2 = await walletClient.writeContract(request2);
		await publicClient.waitForTransactionReceipt({ hash: hash2 });

    await refresh();
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
		if (window.ethereum) {
			window.ethereum.on('accountsChanged', (accounts: string[]) => {
				walletAddress = accounts[0] as Address;
			});
			walletClient = createWalletClient({
				chain,
				transport: custom(window.ethereum!)
			});
		} else {
			alert('Install web3 extension like Rabby or Metamask');
		}

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

		await refresh();

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
		Batch creating Balance <span>{bzzAmount} Bzz | {displayDuration(rBalh)}</span>
	</p>
	<p>
		Batch remaining Balance <span>{bzzAmount0} Bzz | {displayDuration(balh)}</span>
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
