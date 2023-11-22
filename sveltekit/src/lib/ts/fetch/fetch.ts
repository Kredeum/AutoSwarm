import { fetchJson } from './fetchJson';
import { fetchAltUrl } from './fetchAlt';
import { utilsError } from '../swarm/utils';

const fetchContentType = async (url: URL): Promise<string | undefined> => {
	// console.info('fetchContentType', url);

	try {
		const response = await fetch(url, { method: 'HEAD' });
		if (200 === response.status) {
			const type = response.headers.get('content-type');
			// console.info('fetchContentType', type, url);
			return type || 'text';
		} else {
			console.info(`fetchContentType failed with bad status ${response.status} ${url}`);
		}
	} catch (e) {
		utilsError(`fetchContentType: Error ${url}`, e);
	}
};

const fetchUrlOk = async (url: URL | string | undefined): Promise<boolean> =>
	url ? Boolean(await fetchContentType(new URL(url))) : false;

export { fetchContentType, fetchUrlOk, fetchAltUrl, fetchJson };
