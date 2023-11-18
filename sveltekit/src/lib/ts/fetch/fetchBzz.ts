import { SWARM_DEFAULT_API, SWARM_DEFAULT_BATCHID, SWARM_GATEWAY } from '../constants/constants';
import { utilsError } from '../swarm/utils';
import { localConfigGet } from '../constants/local';
import { fetchUrlOk } from './fetch';

const fetchBzzPost = async (url: string | undefined): Promise<string | undefined> => {
	if (!(url && fetchUrlOk(url))) throw new Error('Bad Url');

	const swarmApiUrl = localConfigGet('api') || SWARM_DEFAULT_API;
	const batchId = (localConfigGet('batchId') || SWARM_DEFAULT_BATCHID).replace(/^0x/, '');
  if (batchId === ZERO_BYTES32) throw new Error('No BatchId defined!');

	const body = await (await fetch(url)).blob();

	const headers = new Headers();
	headers.append('Content-Type', body.type);
	headers.append('swarm-postage-batch-id', batchId);

	const response: Response = await fetch(swarmApiUrl, { method: 'POST', body, headers });

	const json = await response.json();
	if (!response.ok) {
		throw Error(`${response.statusText}\n${JSON.stringify(json, null, 2)}`);
	}

	return `${SWARM_GATEWAY}/${json.reference}`;
};

const fetchBzzGet = async (swarmHash: string): Promise<Response | undefined> => {
	console.info('fetchBzzGet', swarmHash);

	try {
		const url = `${SWARM_GATEWAY}/${swarmHash}`;
		const response = await await fetch(url);
		console.log('fetchBzzGet', swarmHash, '\n', response);
		return response;
	} catch (e) {
		utilsError(`fetchBzzGet: Error ${swarmHash}`, e);
	}
};

export { fetchBzzGet, fetchBzzPost };
