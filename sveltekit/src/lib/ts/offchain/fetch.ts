import { IPFS_GATEWAY, SWARM_GATEWAY } from '../constants/constants';

const fetchContentType = async (url: string): Promise<string | undefined> => {
	try {
		const response = await fetch(url, { method: 'HEAD' });
		if (200 === response.status) {
			return response.headers.get('content-type') || 'text';
		} else {
			console.log('fetchContentType failed with bad status', response.status, url);
		}
	} catch (e) {
		console.error('fetchContentType failed with error', e, url);
	}
};

const fetchUrlOk = async (url: string): Promise<boolean> => Boolean(await fetchContentType(url));

const fetchUrlAlt = async (url: string): Promise<string> => {
	if (await fetchUrlOk(url)) return url;

	let tryUrl = url.replace('ipfs://', IPFS_GATEWAY);
	if (tryUrl !== url && (await fetchUrlOk(tryUrl))) return tryUrl;

	tryUrl = url.replace(/^.*\/ipfs\//, IPFS_GATEWAY);
	if (tryUrl !== url && (await fetchUrlOk(tryUrl))) return tryUrl;

	tryUrl = url.replace('swarm://', SWARM_GATEWAY);
	if (tryUrl !== url && (await fetchUrlOk(tryUrl))) return tryUrl;

	throw new Error(`fetchUrlAlt failed ${url}`);
};

const fetchJson = async (url: string): Promise<string> => {
	if (!('application/json' === (await fetchContentType(url))))
		throw new Error(`fetchJson failed ${url} not json`);

	return await (await fetch(url)).json();
};

export { fetchContentType, fetchUrlOk, fetchUrlAlt, fetchJson };
