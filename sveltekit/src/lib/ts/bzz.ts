import { get, writable } from 'svelte/store';

import { jsonGet } from './json';
import { chainGet, type BzzChainIdType } from './chains';

const bzzChainId = writable<number>();

const bzzChain = () => chainGet(get(bzzChainId));

const bzzJson = () => jsonGet(get(bzzChainId) as BzzChainIdType);

export { bzzChain, bzzChainId, bzzJson };
