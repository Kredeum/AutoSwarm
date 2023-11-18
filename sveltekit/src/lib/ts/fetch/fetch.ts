import { fetchJson } from './fetchJson';
import { fetchAltUrl } from './fetchAlt';
import { utilsError } from '../swarm/utils';

const fetchContentType = async (url: string): Promise<string | undefined> => {
	// console.info('fetchContentType', url);

	try {
		const response = await fetch(url, { method: 'HEAD' });
		if (200 === response.status) {
			const type = response.headers.get('content-type');
			// console.info('fetchContentType', type, url);
			return type || 'text';
		} else {
			throw Error(`fetchContentType failed with bad status ${response.status} ${url}`);
		}
	} catch (e) {
		utilsError(`fetchContentType: Error ${url}`, e);
	}
};

const fetchUrlOk = async (url: string | undefined): Promise<boolean> =>
	url ? Boolean(await fetchContentType(url)) : false;

export { fetchContentType, fetchUrlOk, fetchAltUrl, fetchJson };
