import { IPFS_GATEWAY, SWARM_GATEWAY } from '../constants/constants';

const fetchContentType = async (url: string): Promise<string | undefined> => {
	// console.info('fetchContentType', url);

	try {
		const response = await fetch(url, { method: 'HEAD' });
		if (200 === response.status) {
			const type = response.headers.get('content-type');
			console.info('fetchContentType', type, url);
			return type || 'text';
		} else {
			console.log('fetchContentType failed with bad status', response.status, url);
		}
	} catch (e) {
		console.error('fetchContentType failed with error', e, url);
	}
};

const fetchUrlOk = async (url: string): Promise<boolean> => Boolean(await fetchContentType(url));

const fetchUrlAlt = async (url: string): Promise<string> => {
	let tryUrl = url.replace('ipfs://', IPFS_GATEWAY);
	if (tryUrl !== url && (await fetchUrlOk(tryUrl))) return tryUrl;

	tryUrl = url.replace('swarm://', SWARM_GATEWAY);
	if (tryUrl !== url && (await fetchUrlOk(tryUrl))) return tryUrl;

	if (await fetchUrlOk(url)) return url;

	tryUrl = url.replace(/^.*\/ipfs\//, IPFS_GATEWAY);
	if (tryUrl !== url && (await fetchUrlOk(tryUrl))) return tryUrl;

	return url;
	// throw new Error(`fetchUrlAlt failed ${url}`);
};

const fetchJson = async (url: string): Promise<string> => {
	// console.info('fetchJson', url);
	return await (await fetch(url)).json();
};

export { fetchContentType, fetchUrlOk, fetchUrlAlt, fetchJson };
