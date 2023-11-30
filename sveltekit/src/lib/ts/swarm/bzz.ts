import { get, writable } from 'svelte/store';

import { jsonGet } from '../common/json';
import { chainGet, type BzzChainIdType } from '../common/chains';
import type { Hex } from 'viem';

const bzzChainId = writable<number>();

const bzzChain = () => chainGet(get(bzzChainId));

const bzzJson = () => jsonGet(get(bzzChainId) as BzzChainIdType);

const bzzTokenUri = (bzzHash: Hex): string => {
	const hash = bzzHash.replace(/^0x/, '');
	return `bzz://${hash}/metadata.json`;
};

const bzzImage = (bzzHash: Hex): string => {
	const hash = bzzHash.replace(/^0x/, '');
	return `bzz://${hash}/image`;
};

const bzz = (str: string): string => `bzz://${str}`;

export { bzz, bzzChain, bzzChainId, bzzJson, bzzTokenUri, bzzImage };
