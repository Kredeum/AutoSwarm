import { get, writable } from 'svelte/store';

import { jsonGet } from '../common/json';
import { chainGet, type BzzChainIdType } from '../common/chains';
import type { Hex } from 'viem';
import {
	CONTENT,
	INDEX_JSON,
	METADATA,
	SWARM_DEFAULT_API,
	ZERO_BYTES32
} from '../constants/constants';
import { utilsIsBytes32Null } from '../common/utils';
import { localConfigGet } from '../common/local';
import { fetchJson } from '../fetch/fetchJson';

type IndexJsonType = { metadata: string; content: string };

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

const bzzRefs = async (hash: Hex | undefined): Promise<[string, string] | undefined> => {
	if (utilsIsBytes32Null(hash)) return;

	const api = `${localConfigGet('api') || SWARM_DEFAULT_API}/bzz`;
	const url = `${api}/${bzzTrim(hash)}/${INDEX_JSON}`;
	// console.info('bzzRefs', url);

	const json = (await fetchJson(url)) as IndexJsonType;
	// console.info('bzzRefs ~ json', json);

  return [`${hash}/${json[METADATA]}`, `${hash}/${json[CONTENT]}`];
};

export { bzz, bzz0, bzzTrim, bzzChain, bzzChainId, bzzJson, bzzRefs };
