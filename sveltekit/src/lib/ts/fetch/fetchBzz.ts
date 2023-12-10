import { SWARM_DEFAULT_API, SWARM_DEFAULT_BATCHID, SWARM_GATEWAY } from '../constants/constants';
import { localConfigGet } from '../common/local';
import { fetchSuccess, fetchUrl, fetchUrlOk } from './fetch';
import { fetchAltUrl } from './fetchAlt';

import type { Hex } from 'viem';
import { bzzTrim } from '../swarm/bzz';

const fetchBzzGet = async (bzzHash: Hex): Promise<Response | undefined> => {
	console.info('fetchBzzGet', bzzHash);

	const url = `${SWARM_GATEWAY}/${bzzHash}`;
	const response = await fetchUrl(url);
	// console.info('fetchBzzGet', bzzHash, '\n', response);
	return response;
};

const fetchBzzPost = async (
	api: URL | string,
	body: BodyInit | undefined,
	headers: Headers | undefined
): Promise<Hex> => {
	const response = await fetch(api, { method: 'POST', body, headers });
	console.log('response:', response);
	if (!fetchSuccess(response.status)) throw Error(`fetchBzzPost: ${response.status}`);

	const json = await response.json();
	// console.info("fetchBzzPost", json);
	return `0x${json.reference}`;
};

const fetchBzzPostFromUrl = async (
	url: URL | string | undefined,
	batchId?: Hex,
	api?: string
): Promise<Hex> => {
	if (!(url && fetchUrlOk(url))) throw new Error(`fetchBzzPostFromUrl: Bad URL ${url}`);

	batchId ||= (localConfigGet('batchId') || SWARM_DEFAULT_BATCHID) as Hex;
	api ||= `${localConfigGet('api') || SWARM_DEFAULT_API}/bzz`;

	const urlAlt = await fetchAltUrl(url);
	if (!urlAlt) throw new Error(`fetchBzzPostFromUrl: Bad URL ${url}`);

	const resp = await fetchUrl(urlAlt);
	if (!resp) throw new Error(`fetchBzzPostFromUrl: Bad URL ${urlAlt}`);
	const body = await resp.blob();
	console.log('fetchBzzPostFromUrl body.type:', body.type);

	const headers = new Headers();
	headers.append('Swarm-Postage-Batch-Id', bzzTrim(batchId));
	headers.append('Content-Type', body.type);

	return fetchBzzPost(api, body, headers);
};

export { fetchBzzGet, fetchBzzPost, fetchBzzPostFromUrl };
