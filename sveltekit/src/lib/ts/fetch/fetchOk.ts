import { fetchContentTypeGet, fetchContentTypeHead } from './fetchContentType';
import { fetchSizeGet, fetchSizeHead } from './fetchSize';

const _fetchOkUrlHead = async (url: URL | string | undefined): Promise<boolean> => {
	// console.info('_fetchOkUrlHead', url);
	return (
		Boolean(url) &&
		(Boolean(await fetchContentTypeHead(url)) || ((await fetchSizeHead(url)) || 0) > 0)
	);
};

const _fetchOkUrlGet = async (url: URL | string | undefined): Promise<boolean> => {
	// console.info('_fetchOkUrlGet', url);
	return (
		Boolean(url) &&
		(Boolean(await fetchContentTypeGet(url)) || ((await fetchSizeGet(url)) || 0) > 0)
	);
};

const fetchOkUrl = async (url: URL | string | undefined): Promise<boolean> => {
	// console.info('fetchOkUrl', url);
	try {
		return (await _fetchOkUrlHead(url)) || (await _fetchOkUrlGet(url));
	} catch (e) {
		console.log('fetchOkUrl', e);
		return false;
	}
};

export { fetchOkUrl };
