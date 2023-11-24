import { get, writable } from 'svelte/store';

import { jsonGet } from '../constants/json';
import { chainGet, type BzzChainIdType } from '../constants/chains';
import type { Hex } from 'viem';

const bzzChainId = writable<number>();

const bzzChain = () => chainGet(get(bzzChainId));

const bzzJson = () => jsonGet(get(bzzChainId) as BzzChainIdType);

const bzzTokenUri = (bzzHash: Hex): URL => new URL(`bzz://${bzzHash}/metadata.json`);

const bzzImageUri = (bzzHash: Hex): URL => new URL(`bzz://${bzzHash}/image`);

export { bzzChain, bzzChainId, bzzJson, bzzTokenUri, bzzImageUri };
