import { fetchAltUrl } from './fetchAlt';
import { utilsError } from '../common/utils';
import { urlToUrl, urlToUrlAlt } from '../common/url';

const fetchContentType = async (url: URL | string | undefined): Promise<string | undefined> => {
	// console.info('fetchContentType', url);
	if (!url) return;

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

const fetchUriOk = async (url: URL | string | undefined): Promise<boolean> =>
	fetchUrlOk(urlToUrl(url));

const fetchUrlAltOk = async (url: URL | string | undefined): Promise<boolean> =>
	fetchUrlOk(urlToUrlAlt(url));

export { fetchContentType, fetchUrlOk, fetchUriOk, fetchUrlAltOk, fetchAltUrl };
