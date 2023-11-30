import { urlToUrl, urlToUrlAlt } from '../common/url';
import { fetchUrlOk } from './fetch';

const fetchAltUrl = async (url: URL | string | undefined): Promise<string | undefined> => {
	const tryUrl = urlToUrl(url);
	if (tryUrl && (await fetchUrlOk(tryUrl))) return tryUrl;

	const tryUrlAlt = urlToUrlAlt(url);
	if (tryUrlAlt && (await fetchUrlOk(tryUrlAlt))) return tryUrlAlt;

	return;
};

export { fetchAltUrl };
