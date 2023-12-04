import { get, writable } from 'svelte/store';

import { jsonGet } from '../common/json';
import { chainGet, type BzzChainIdType } from '../common/chains';
import type { Hex } from 'viem';
import { IMAGE_JPEG, METADATA_JSON } from '../constants/constants';

const bzzChainId = writable<number>();

const bzzChain = () => chainGet(get(bzzChainId));

const bzzJson = () => jsonGet(get(bzzChainId) as BzzChainIdType);

const bzzTokenUri = (bzzHash: Hex): string => {
	const hash = bzzHash.replace(/^0x/, '');
	return `bzz://${hash}/${METADATA_JSON}`;
};

const bzzImage = (bzzHash: Hex): string => {
	const hash = bzzHash.replace(/^0x/, '');
	return `bzz://${hash}/${IMAGE_JPEG}`;
};

const bzz = (str: string): string => `bzz://${str}`;

export { bzz, bzzChain, bzzChainId, bzzJson, bzzTokenUri, bzzImage };
