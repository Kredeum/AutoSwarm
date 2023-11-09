import { get, writable } from 'svelte/store';

import { jsonGet } from './json';
import { chainGet, type ChainIdType } from './chains';

const bzzChainId = writable<number>();

const bzzChain = () => chainGet(get(bzzChainId));

const bzzJson = () => jsonGet(get(bzzChainId) as ChainIdType);

export { bzzChain, bzzChainId, bzzJson };
