import { ARWEAVE_GATEWAY, IPFS_GATEWAY, SWARM_GATEWAY } from '../constants/constants';
import { fetchUrlOk } from './fetch';

const fetchAltUrl = async (url: string): Promise<[string, string | undefined]> => {
	let tryIpfsUrl = url.replace('ipfs://', `${IPFS_GATEWAY}/`);
	if (tryIpfsUrl !== url && (await fetchUrlOk(tryIpfsUrl))) return [tryIpfsUrl, 'ipfs'];

	let trySwarmUrl = url.replace(/(bzz|bzzr|swarm):\/\//, `${SWARM_GATEWAY}/`);
	if (trySwarmUrl !== url && (await fetchUrlOk(trySwarmUrl))) return [trySwarmUrl, 'swarm'];

	let tryArweaveUrl = url.replace('ar://', `${ARWEAVE_GATEWAY}/`);
	if (tryArweaveUrl !== url && (await fetchUrlOk(tryArweaveUrl))) return [tryArweaveUrl, 'arweave'];

	if (await fetchUrlOk(url)) {
		const type = url.includes('/ipfs/')
			? 'ipfs'
			: url.includes('/bzz/')
			  ? 'swarm'
			  : url.includes('arweave.net/') || url.includes('/ar/')
			    ? 'arweave'
			    : undefined;
		console.log('fetchAltUrl ~ type:', type);
		return [url, type];
	}

	tryIpfsUrl = url.replace(/^.*\/ipfs\//, `${IPFS_GATEWAY}/`);
	if (tryIpfsUrl !== url && (await fetchUrlOk(tryIpfsUrl))) return [tryIpfsUrl, 'ipfs'];

	trySwarmUrl = url.replace(/^.*\/bzz\//, `${SWARM_GATEWAY}/`);
	if (trySwarmUrl !== url && (await fetchUrlOk(trySwarmUrl))) return [trySwarmUrl, 'swarm'];

	tryArweaveUrl = url.replace(/^.*\/ar\//, `${ARWEAVE_GATEWAY}/`);
	if (tryArweaveUrl !== url && (await fetchUrlOk(tryArweaveUrl))) return [tryArweaveUrl, 'swarm'];

	return [url, undefined];
	// throw new Error(`fetchAltUrl failed ${url}`);
};

export { fetchAltUrl };
