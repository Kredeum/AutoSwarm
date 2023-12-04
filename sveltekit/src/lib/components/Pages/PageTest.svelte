<script lang="ts">
	import { type Address, createPublicClient, http, parseAbi, type Hex } from 'viem';
	import { mainnet } from 'viem/chains';

	let tokenURI: string | undefined;

	const readTokenUri = async () => {
		const chain = mainnet;
		const transport = http('https://rpc.ankr.com/eth');
		const address = '0x5c211B8E4f93F00E2BD68e82F4E00FbB3302b35c' as Address;
		const abi = parseAbi([
			'function tokenURI(uint256) external view returns (string)',
			'function supportsInterface(bytes4) external view returns (bool)'
		]);
		const functionName = 'supportsInterface';
		const args = ['0xd9b67a26'] as [Hex];

		const publicClient = createPublicClient({ chain, transport });
		return await publicClient.readContract({ address, abi, functionName, args });
	};
</script>

<div id="test">
	{#await readTokenUri()}
		<p>Loading...</p>
	{:then tokenURI}
		<p>isERC1155? : {tokenURI}</p>
	{:catch error}
		<p>Error:</p>
		<pre>
    {error.message}
  </pre>
	{/await}
</div>

<style>
	div#test {
		display: block;
		text-align: left;
	}
</style>
