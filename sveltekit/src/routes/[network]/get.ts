import type { Chain } from 'viem';

import jsonFile from '../../../../addresses.json';

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

const getDisplayDuration = (duration = 0): string => {
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

const getExplorerLink = (chain: Chain, addr: string): string => {
	const explorer =
		chain?.blockExplorers?.etherscan?.url || chain?.blockExplorers?.default?.url || '';

	return `<a href="${explorer}/address/${addr}" target="_blank">${addr}</a>`;
};

export { getJson, getDisplayDuration, getExplorerLink, type ChainIdInJson };
