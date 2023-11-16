import { ARWEAVE_GATEWAY, IPFS_GATEWAY, SWARM_GATEWAY } from '../constants/constants';

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

const fetchUrlAlt = async (url: string): Promise<[string, string | undefined]> => {
	let tryIpfsUrl = url.replace('ipfs://', IPFS_GATEWAY);
	if (tryIpfsUrl !== url && (await fetchUrlOk(tryIpfsUrl))) return [tryIpfsUrl, 'ipfs'];

	let trySwarmUrl = url.replace(/(bzz|bzzr|swarm):\/\//, SWARM_GATEWAY);
	if (trySwarmUrl !== url && (await fetchUrlOk(trySwarmUrl))) return [trySwarmUrl, 'swarm'];

	let tryArweaveUrl = url.replace('ar://', ARWEAVE_GATEWAY);
	if (tryArweaveUrl !== url && (await fetchUrlOk(tryArweaveUrl))) return [tryArweaveUrl, 'arweave'];

	if (await fetchUrlOk(url)) {
		const type = url.includes('/ipfs/')
			? 'ipfs'
			: url.includes('/bzz/')
			  ? 'swarm'
			  : url.includes('arweave.net/') || url.includes('/ar/')
			    ? 'arweave'
			    : undefined;
		console.log('fetchUrlAlt ~ type:', type);
		return [url, type];
	}

	tryIpfsUrl = url.replace(/^.*\/ipfs\//, IPFS_GATEWAY);
	if (tryIpfsUrl !== url && (await fetchUrlOk(tryIpfsUrl))) return [tryIpfsUrl, 'ipfs'];

	trySwarmUrl = url.replace(/^.*\/bzz\//, SWARM_GATEWAY);
	if (trySwarmUrl !== url && (await fetchUrlOk(trySwarmUrl))) return [trySwarmUrl, 'swarm'];

	tryArweaveUrl = url.replace(/^.*\/ar\//, ARWEAVE_GATEWAY);
	if (tryArweaveUrl !== url && (await fetchUrlOk(tryArweaveUrl))) return [tryArweaveUrl, 'swarm'];

	return [url, undefined];
	// throw new Error(`fetchUrlAlt failed ${url}`);
};

const fetchJson = async (url: string): Promise<unknown | undefined> => {
	// console.info('fetchJson', url);

	try {
		const json = await (await fetch(url)).json();
		console.log('fetchJson', url, '\n', json);
		return json;
	} catch (e) {
		console.log('fetchJson failed with error', e, url);
	}
};

export { fetchContentType, fetchUrlOk, fetchUrlAlt, fetchJson };
