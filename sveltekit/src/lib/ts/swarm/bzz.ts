import { get, writable } from 'svelte/store';

import { addressesGet } from '../common/addresses';
import { chainGet } from '../common/chains';
import type { Chain, Hex } from 'viem';
import { LIST_JSON, ZERO_BYTES32 } from '../constants/constants';
import { utilsIsNullBytes32 } from '../common/utils';
import { fetchJson } from '../fetch/fetchJson';
import type { AddressesType } from '../constants/types';
import { beeApiBzz } from './bee';

type ListJsonType = { metadata: string; image: string };

const bzzChainId = writable<number>();

const bzzChain = (): Chain | undefined => chainGet(get(bzzChainId));

const bzzJson = (): AddressesType => addressesGet(get(bzzChainId));

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

const bzzImageName = async (hash: Hex | undefined): Promise<string | undefined> => {
	if (utilsIsNullBytes32(hash)) return;

	const url = `${beeApiBzz()}/${bzzTrim(hash)}/${LIST_JSON}`;
	// console.info('bzzImageName', url);

	const json = (await fetchJson(url)) as ListJsonType;
	// console.info('bzzImageName ~ json', json);

	return json['image'];
};

export { bzz, bzz0, bzzTrim, bzzChain, bzzChainId, bzzJson, bzzImageName };
