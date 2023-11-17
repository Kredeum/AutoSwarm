import { fetchJson } from './fetchJson';
import { fetchAltUrl } from './fetchAlt';


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

export { fetchContentType, fetchUrlOk, fetchAltUrl, fetchJson };
