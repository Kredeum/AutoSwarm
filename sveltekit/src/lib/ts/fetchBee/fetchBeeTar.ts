import type { Hex } from 'viem';

import { INDEX_HTML } from '../constants/constants';
import { fetchBeePost } from './fetchBee';
import { bzz0, bzzTrim } from '../swarm/bzz';
import { beeBatchId, beeApiBzz } from '../swarm/bee';

const fetchBeeTarPost = async (body: Uint8Array | undefined): Promise<Hex> => {
	if (!body) throw new Error('fetchBeeTarPost: No body defined!');
	// console.log('fetchBeeTarPost ~ body.length', body.length);

	const api = beeApiBzz();
	const batchId = beeBatchId();
	if (!bzz0(batchId)) throw new Error('fetchNftTar: No BatchId defined!');

	const headers = new Headers();
	headers.append('Accept', 'application/json, text/plain, */*');
	headers.append('Content-Type', 'application/x-tar');
	headers.append('Swarm-Postage-Batch-Id', bzzTrim(batchId));
	headers.append('Swarm-Pin', 'true');
	headers.append('Swarm-Collection', 'true');
	headers.append('Swarm-Index-Document', INDEX_HTML);

	const hash = await fetchBeePost(api, body, headers);
	console.info('fetchBeeTarPost hash:', hash);

	return hash;
};

export { fetchBeeTarPost };
