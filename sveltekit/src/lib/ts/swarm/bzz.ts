import { get, writable } from 'svelte/store';

import { jsonGet } from '../common/json';
import { chainGet, type BzzChainIdType } from '../common/chains';
import type { Hex } from 'viem';
import { IMAGE_JPEG, METADATA_JSON, ZERO_BYTES32 } from '../constants/constants';

const bzzChainId = writable<number>();

const bzzChain = () => chainGet(get(bzzChainId));

const bzzJson = () => jsonGet(get(bzzChainId) as BzzChainIdType);

const bzzTrim = (hash: Hex | string | undefined): string =>
	hash
		? hash
				.toString()
				.trim()
				.replace(/^bzz\/\//, '')
				.replace(/^0x/, '')
		: '';

const bzz = (hash: Hex | string | undefined): string => (hash ? `bzz://${bzzTrim(hash)}` : '');

const bzz0 = (hash: Hex | string): Hex | undefined => (hash ? `0x${bzzTrim(hash)}` : ZERO_BYTES32);

const bzzTokenUri = (hash: Hex | string | undefined): string => `${bzz(hash)}/${METADATA_JSON}`;

const bzzImage = (hash: Hex | string | undefined): string => `${bzz(hash)}/${IMAGE_JPEG}`;

export { bzz, bzz0, bzzTrim, bzzChain, bzzChainId, bzzJson, bzzTokenUri, bzzImage };
