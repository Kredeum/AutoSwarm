import { isAddress, type Address } from 'viem';
import { UNDEFINED_ADDRESS } from '$lib/ts/constants/constants';

import { chainGetExplorer } from '../common/chains';
import { addressesGetField } from '../common/addresses';
import { utilsTruncate } from '../common/utils';

///////////////////////////////////////////////////////////////////////////////////////////////////
// DISPLAY : offline functions returns [html] string to display
///////////////////////////////////////////////////////////////////////////////////////////////////

const displayExplorer = (chainId: number | undefined): string => {
	if (!chainId) return '';
	const explorer = chainGetExplorer(chainId);
	if (!explorer) return `#${chainId}`;

	return `<a href="${explorer}" target="_blank">#${chainId}</a>`;
};

const displayExplorerNft = (
	chainId: number | undefined,
	collection: string | undefined,
	tokenId: bigint | undefined
): string => {
	if (!(chainId && collection && tokenId && tokenId >= 0)) return '';
	const explorer = chainGetExplorer(chainId);
	if (!explorer) return `#${chainId}`;

	return `<a href="${explorer}/nft/${collection}/${tokenId}" target="_blank">#${utilsTruncate(
		tokenId.toString()
	)}</a>`;
};

const _displayExplorerAddress = (
	chainId: number | undefined,
	addr: Address | undefined
): string => {
	if (!chainId) return '';

	const explorer = chainGetExplorer(chainId);
	// console.log('explorer:', explorer);
	if (!explorer) return `${addr}`;

	return `<a href="${explorer}/address/${addr}" target="_blank">${addr}</a>`;
};

const displayExplorerAddress = (chainId: number | undefined, addr: Address | undefined): string => {
	console.log('displayExplorerAddress ~  addr && isAddress(addr):', addr && isAddress(addr));

	return chainId && addr && isAddress(addr)
		? _displayExplorerAddress(chainId, addr)
		: UNDEFINED_ADDRESS;
};
const displayExplorerField = (chainId: number, field: string): string =>
	displayExplorerAddress(chainId, addressesGetField(chainId, field) as Address);

export { displayExplorer, displayExplorerNft, displayExplorerAddress, displayExplorerField };
