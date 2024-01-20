import { fetchSuccess, fetchUrl } from '../fetch/fetch';
import { fetchOkUrl } from '../fetch/fetchOk';
import { fetchAltUrl } from '../fetch/fetchAlt';

import type { Hex } from 'viem';
import { bzzTrim } from '../swarm/bzz';
import { beeApiBzz, beeGatewayBzz, beeBatchId } from '../swarm/bee';

const fetchBeeGet = async (swarmHash: Hex): Promise<Response | undefined> => {
	console.info('fetchBeeGet', swarmHash);

	const url = `${beeGatewayBzz()}/${swarmHash}`;
	const response = await fetchUrl(url);
	// console.info('fetchBeeGet', swarmHash, '\n', response);
	return response;
};

const fetchBeePost = async (
	api: URL | string,
	body: FormData | Blob | Uint8Array | string,
	headers: Headers
): Promise<Hex> => {
	// console.log('fetchBeePost:', api, body.length, JSON.stringify(headers, null, 2));

	const response = await fetch(api, { method: 'POST', body, headers });
	// console.log('response:', response);
	if (!fetchSuccess(response.status)) throw new Error(`fetchBeePost: ${response.status}`);

	const json = await response.json();
	// console.info("fetchBeePost", json);
	return `0x${json.reference}`;
};

const fetchBeePostFromUrl = async (
	url: URL | string | undefined,
	batchId?: Hex,
	api?: string
): Promise<Hex> => {
	if (!(url && fetchOkUrl(url))) throw new Error(`fetchBeePostFromUrl: Bad URL ${url}`);

	api ||= beeApiBzz();
	batchId ||= beeBatchId();

	const urlAlt = await fetchAltUrl(url);
	if (!urlAlt) throw new Error(`fetchBeePostFromUrl: Bad URL ${url}`);

	const resp = await fetchUrl(urlAlt);
	if (!resp) throw new Error(`fetchBeePostFromUrl: Bad URL ${urlAlt}`);
	const body = await resp.blob();
	console.log('fetchBeePostFromUrl body.type:', body.type);

	const headers = new Headers();
	headers.append('Swarm-Postage-Batch-Id', bzzTrim(batchId));
	headers.append('Content-Type', body.type);

	return await fetchBeePost(api, body, headers);
};

export { fetchBeeGet, fetchBeePost, fetchBeePostFromUrl };
