import { urlToUrl, urlToUrlAlt } from '../common/url';
import { fetchUrlOk } from './fetch';

const fetchAltUrl = async (url: URL | string | undefined): Promise<string | undefined> => {
	// console.info('fetchAltUrl  IN', url);
	const tryUrl = urlToUrl(url);
	if (tryUrl && (await fetchUrlOk(tryUrl))) return tryUrl;

	const tryUrlAlt = urlToUrlAlt(url);
	if (tryUrlAlt && tryUrlAlt !== tryUrl && (await fetchUrlOk(tryUrlAlt))) return tryUrlAlt;

	// console.info('fetchAltUrl OUT');
	return url?.toString();
};

export { fetchAltUrl };
