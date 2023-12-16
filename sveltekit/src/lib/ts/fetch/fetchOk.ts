import { urlToUrl, urlToUrlAlt } from '../common/url';
import { fetchContentTypeGet, fetchContentTypeHead } from './fetchContentType';
import { fetchSizeGet, fetchSizeHead } from './fetchSize';

const fetchOkUrlHead = async (url: URL | string | undefined): Promise<boolean> => {
	// console.info('fetchOkUrlHead', url);
	return (
		Boolean(url) &&
		(Boolean(await fetchContentTypeHead(url)) || ((await fetchSizeHead(url)) || 0) > 0)
	);
};

const fetchOkUrlGet = async (url: URL | string | undefined): Promise<boolean> => {
	// console.info('fetchOkUrlGet', url);
	return (
		Boolean(url) &&
		(Boolean(await fetchContentTypeGet(url)) || ((await fetchSizeGet(url)) || 0) > 0)
	);
};

const fetchOkUrl = async (url: URL | string | undefined): Promise<boolean> => {
	// console.info('fetchOkUrl', url);
	return (await fetchOkUrlHead(url)) || (await fetchOkUrlGet(url));
};

const fetchOkUri = async (url: URL | string | undefined): Promise<boolean> => {
	// console.info('fetchOkUri', url);
	return await fetchOkUrl(urlToUrl(url));
};

const fetchOkUrlAlt = async (url: URL | string | undefined): Promise<boolean> => {
	// console.info('fetchOkUrlAlt', url);
	return await fetchOkUrl(urlToUrlAlt(url));
};
export { fetchOkUrl, fetchOkUri, fetchOkUrlAlt };
