import { ARWEAVE_GATEWAY, IPFS_GATEWAY, SWARM_GATEWAY } from '../constants/constants';

const urlToUrl = (uri: URL | string | undefined): string | undefined => {
	const url = uri?.toString();
	if (!url) return;

	const tryIpfsUrl = url.replace('ipfs://', `${IPFS_GATEWAY}/`);
	if (tryIpfsUrl !== url) return tryIpfsUrl;

	const trySwarmUrl = url.replace(/(bzz|bzzr|swarm):\/\//, `${SWARM_GATEWAY}/`);
	if (trySwarmUrl !== url) return trySwarmUrl;

	const tryArweaveUrl = url.replace('ar://', `${ARWEAVE_GATEWAY}/`);
	if (tryArweaveUrl !== url) return tryArweaveUrl;

	return url;
};

const urlToUrlAlt = (uri: URL | string | undefined): string | undefined => {
	const url = urlToUrl(uri);
	if (!url) return;
	if (url !== uri?.toString()) return url;

	const tryIpfsUrl = url.replace(/^.*\/ipfs\//, `${IPFS_GATEWAY}/`);
	if (tryIpfsUrl !== url) return tryIpfsUrl;

	const trySwarmUrl = url.replace(/^.*\/bzz\//, `${SWARM_GATEWAY}/`);
	if (trySwarmUrl !== url) return trySwarmUrl;

	const tryArweaveUrl = url.replace(/^.*\/ar\//, `${ARWEAVE_GATEWAY}/`);
	if (tryArweaveUrl !== url) return tryArweaveUrl;

	return url;
};

export { urlToUrl, urlToUrlAlt };
