import {
	ARWEAVE_GATEWAY_DEFAULT,
	IPFS_GATEWAY_DEFAULT,
	BEE_GATEWAY_DEFAULT
} from '../constants/constants';

const urlToUrl = (uri: URL | string | undefined): string | undefined => {
	const url = uri?.toString();
	if (!url) return;

	const tryIpfsUrl = url.replace('ipfs://', `${IPFS_GATEWAY_DEFAULT}/`);
	if (tryIpfsUrl !== url) return tryIpfsUrl;

	const trySwarmUrl = url.replace(/(bzz|bzzr|swarm):\/\//, `${BEE_GATEWAY_DEFAULT}/`);
	if (trySwarmUrl !== url) return trySwarmUrl;

	const tryArweaveUrl = url.replace('ar://', `${ARWEAVE_GATEWAY_DEFAULT}/`);
	if (tryArweaveUrl !== url) return tryArweaveUrl;

	return url;
};

const urlToUrlAlt = (uri: URL | string | undefined): string | undefined => {
	const url = urlToUrl(uri);
	if (!url) return;
	if (url !== uri?.toString()) return url;

	const tryIpfsUrl = url.replace(/^.*\/ipfs\//, `${IPFS_GATEWAY_DEFAULT}/`);
	if (tryIpfsUrl !== url) return tryIpfsUrl;

	const trySwarmUrl = url.replace(/^.*\/bzz\//, `${BEE_GATEWAY_DEFAULT}/`);
	if (trySwarmUrl !== url) return trySwarmUrl;

	const tryArweaveUrl = url.replace(/^.*\/ar\//, `${ARWEAVE_GATEWAY_DEFAULT}/`);
	if (tryArweaveUrl !== url) return tryArweaveUrl;

	return url;
};

export { urlToUrl, urlToUrlAlt };
