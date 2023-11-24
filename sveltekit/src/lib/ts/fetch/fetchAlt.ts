import { ARWEAVE_GATEWAY, IPFS_GATEWAY, SWARM_GATEWAY } from '../constants/constants';
import { fetchUrlOk } from './fetch';

// const type = urlToString.includes('/ipfs/')
//   ? 'ipfs'
//   : urlToString.includes('/bzz/')
//     ? 'swarm'
//     : urlToString.includes('arweave.net/') || urlToString.includes('/ar/')
//       ? 'arweave'
//       : undefined;

const fetchAltUrl = async (url: URL | undefined): Promise<URL | undefined> => {
	if (!url) return;
	const urlToString = url.toString();

	let tryIpfsUrl = urlToString.replace('ipfs://', `${IPFS_GATEWAY}/`);
	if (tryIpfsUrl !== urlToString && (await fetchUrlOk(tryIpfsUrl))) return new URL(tryIpfsUrl);

	let trySwarmUrl = urlToString.replace(/(bzz|bzzr|swarm):\/\//, `${SWARM_GATEWAY}/`);
	if (trySwarmUrl !== urlToString && (await fetchUrlOk(trySwarmUrl))) return new URL(trySwarmUrl);

	let tryArweaveUrl = urlToString.replace('ar://', `${ARWEAVE_GATEWAY}/`);
	if (tryArweaveUrl !== urlToString && (await fetchUrlOk(tryArweaveUrl)))
		return new URL(tryArweaveUrl);

	if (await fetchUrlOk(urlToString)) return new URL(urlToString);

	tryIpfsUrl = urlToString.replace(/^.*\/ipfs\//, `${IPFS_GATEWAY}/`);
	if (tryIpfsUrl !== urlToString && (await fetchUrlOk(tryIpfsUrl))) return new URL(tryIpfsUrl);

	trySwarmUrl = urlToString.replace(/^.*\/bzz\//, `${SWARM_GATEWAY}/`);
	if (trySwarmUrl !== urlToString && (await fetchUrlOk(trySwarmUrl))) return new URL(trySwarmUrl);

	tryArweaveUrl = urlToString.replace(/^.*\/ar\//, `${ARWEAVE_GATEWAY}/`);
	if (tryArweaveUrl !== urlToString && (await fetchUrlOk(tryArweaveUrl)))
		return new URL(tryArweaveUrl);

	return url;
	// throw new Error(`fetchAltUrl failed ${url}`);
};

export { fetchAltUrl };
