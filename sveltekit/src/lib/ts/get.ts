import type { Chain } from 'viem';

import jsonFile from '$addresses';

///////////////////////////////////////////////////////////////////////////////////////////////////
// GET : offline functions
///////////////////////////////////////////////////////////////////////////////////////////////////

enum ChainIdInJson {
	'gnosis' = 100,
	'sepolia' = 11155111,
	'localhost' = 1337
}

const getJson = (chainId: ChainIdInJson) => {
	return jsonFile[chainId];
};
const getBatchId = (chainId: ChainIdInJson): string => {
	return getJson(chainId).batchId;
};

const getDisplayDuration = (seconds = 0n): string => {
	const hours = Number(seconds) / 3600;
	const days = hours / 24;
	const weeks = days / 7;

	const ret =
		hours < 24
			? `${hours.toFixed(2)} hours`
			: days < 7
			? `${days.toFixed(2)} days`
			: `${weeks.toFixed(2)} weeks`;
 
	return ret;
};

const getExplorerLink = (chain: Chain, addr: string): string => {
	const explorer =
		chain?.blockExplorers?.etherscan?.url || chain?.blockExplorers?.default?.url || '';

	return `<a href="${explorer}/address/${addr}" target="_blank">${addr}</a>`;
};

export { getJson, getBatchId, getDisplayDuration, getDisplayDuration2, getExplorerLink, type ChainIdInJson };
